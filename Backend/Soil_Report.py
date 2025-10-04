import logging
import os
from datetime import datetime, date, timedelta
from dateutil.relativedelta import relativedelta
import streamlit as st
import folium
from streamlit_folium import st_folium
import ee
import pandas as pd
from folium.plugins import Draw
import matplotlib.pyplot as plt
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import cm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle, PageBreak
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER
from reportlab.pdfgen import canvas
from io import BytesIO
import sys
sys.path.append(r'C:\Users\pavan\AppData\Roaming\Python\Python313\site-packages')
import google.generativeai as genai

# Configuration
API_KEY = "AIzaSyAWA9Kqh2FRtBmxRZmNlZ7pcfasG5RJmR8"
MODEL = "models/gemini-1.5-flash"
LOGO_PATH = os.path.abspath("LOGO.jpg")
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Initialize Google Earth Engine
try:
    ee.Initialize()
except Exception:
    ee.Authenticate()
    ee.Initialize()

# Constants & Lookups
SOIL_TEXTURE_IMG = ee.Image("OpenLandMap/SOL/SOL_TEXTURE-CLASS_USDA-TT_M/v02").select('b0')
TEXTURE_CLASSES = {
    1: "Clay", 2: "Silty Clay", 3: "Sandy Clay",
    4: "Clay Loam", 5: "Silty Clay Loam", 6: "Sandy Clay Loam",
    7: "Loam", 8: "Silty Loam", 9: "Sandy Loam",
    10: "Silt", 11: "Loamy Sand", 12: "Sand"
}
IDEAL_RANGES = {
    "pH":           (6.0, 7.5),
    "Soil Texture": 7,
    "Salinity":     (None, 0.2),
    "Organic Carbon": (0.02, 0.05),
    "CEC":            (10, 30),
    "LST":            (10, 30),
    "NDVI":           (0.2, 0.8),
    "EVI":            (0.2, 0.8),
    "FVC":            (0.3, 0.8),
    "NDWI":           (-0.5, 0.5),
    "Nitrogen":       (280, 450),
    "Phosphorus":     (20, 50),
    "Potassium":      (150, 300)
}

# Utility Functions
def safe_get_info(computed_obj, name="value"):
    if computed_obj is None:
        return None
    try:
        info = computed_obj.getInfo()
        return float(info) if info is not None else None
    except Exception as e:
        logging.warning(f"Failed to fetch {name}: {e}")
        return None

def sentinel_composite(region, start, end, bands):
    start_str = start.strftime("%Y-%m-%d")
    end_str = end.strftime("%Y-%m-%d")
    try:
        coll = (
            ee.ImageCollection("COPERNICUS/S2_SR_HARMONIZED")
            .filterDate(start_str, end_str)
            .filterBounds(region)
            .filter(ee.Filter.lt("CLOUDY_PIXEL_PERCENTAGE", 20))
            .select(bands)
        )
        if coll.size().getInfo() > 0:
            return coll.median().multiply(0.0001)
        for days in range(5, 31, 5):
            sd = (start - timedelta(days=days)).strftime("%Y-%m-%d")
            ed = (end + timedelta(days=days)).strftime("%Y-%m-%d")
            coll = (
                ee.ImageCollection("COPERNICUS/S2_SR_HARMONIZED")
                .filterDate(sd, ed)
                .filterBounds(region)
                .filter(ee.Filter.lt("CLOUDY_PIXEL_PERCENTAGE", 30))
                .select(bands)
            )
            if coll.size().getInfo() > 0:
                logging.info(f"Sentinel window expanded to {sd}–{ed}")
                return coll.median().multiply(0.0001)
        logging.warning("No Sentinel-2 data available.")
        return None
    except Exception as e:
        logging.error(f"Error in sentinel_composite: {e}")
        return None

def get_lst(region, start, end):
    end_dt = end
    start_dt = end_dt - relativedelta(months=1)
    start_str = start_dt.strftime("%Y-%m-%d")
    end_str = end_dt.strftime("%Y-%m-%d")
    logging.info(f"Fetching MODIS LST from {start_str} to {end_str}")
    try:
        coll = (
            ee.ImageCollection("MODIS/061/MOD11A2")
            .filterBounds(region.buffer(5000))
            .filterDate(start_str, end_str)
            .select("LST_Day_1km")
        )
        cnt = coll.size().getInfo()
        if cnt == 0:
            logging.warning("No LST images in the specified range.")
            return None
        img = coll.median().multiply(0.02).subtract(273.15).rename("lst").clip(region.buffer(5000))
        stats = img.reduceRegion(reducer=ee.Reducer.mean(), geometry=region, scale=1000, maxPixels=1e13).getInfo()
        lst_value = stats.get("lst")
        return float(lst_value) if lst_value is not None else None
    except Exception as e:
        logging.error(f"Error in get_lst: {e}")
        return None

def get_ph(comp, region):
    if comp is None:
        return None
    try:
        br = comp.expression("(B2+B3+B4)/3", {"B2": comp.select("B2"), "B3": comp.select("B3"), "B4": comp.select("B4")})
        sa = comp.expression("(B11-B8)/(B11+B8+1e-6)", {"B11": comp.select("B11"), "B8": comp.select("B8")})
        img = comp.expression("7.1", {"B2": comp.select("B2"), "B11": comp.select("B11"), "br": br, "sa": sa}).rename("ph")
        return safe_get_info(img.reduceRegion(ee.Reducer.mean(), geometry=region, scale=10, maxPixels=1e13).get("ph"), "pH")
    except Exception as e:
        logging.error(f"Error in get_ph: {e}")
        return None

def get_salinity(comp, region):
    if comp is None:
        return None
    try:
        img = comp.expression("(B11)/(B3)", {"B11": comp.select("B11"), "B3": comp.select("B3")}).rename("ndsi")
        return safe_get_info(img.reduceRegion(ee.Reducer.mean(), geometry=region, scale=10, maxPixels=1e13).get("ndsi"), "salinity")
    except Exception as e:
        logging.error(f"Error in get_salinity: {e}")
        return None

def get_organic_carbon(comp, region):
    if comp is None:
        return None
    try:
        ndvi = comp.normalizedDifference(["B8", "B4"])
        img = ndvi.multiply(0.05).rename("oc")
        return safe_get_info(img.reduceRegion(ee.Reducer.mean(), geometry=region, scale=10, maxPixels=1e13).get("oc"), "organic carbon")
    except Exception as e:
        logging.error(f"Error in get_organic_carbon: {e}")
        return None

def estimate_cec(comp, region, intercept, slope_clay, slope_om):
    if comp is None:
        return None
    try:
        clay = comp.expression("(B11)/(B11)", {"B11": comp.select("B11"), "B8": comp.select("B8")}).rename("clay")
        om = comp.expression("(B8-B4)/(B8)", {"B8": comp.select("B8"), "B4": comp.select("B4")}).rename("om")
        c_m = safe_get_info(clay.reduceRegion(ee.Reducer.mean(), geometry=region, scale=20, maxPixels=1e13).get("clay"), "clay")
        o_m = safe_get_info(om.reduceRegion(ee.Reducer.mean(), geometry=region, scale=20, maxPixels=1e13).get("om"), "om")
        if c_m is None or o_m is None:
            return None
        return intercept + slope_clay * c_m + slope_om * o_m
    except Exception as e:
        logging.error(f"Error in estimate_cec: {e}")
        return None

def get_soil_texture(region):
    try:
        mode = SOIL_TEXTURE_IMG.clip(region.buffer(500)).reduceRegion(ee.Reducer.mode(), geometry=region, scale=250, maxPixels=1e13).get("b0")
        val = safe_get_info(mode, "texture")
        return int(val) if val is not None else None
    except Exception as e:
        logging.error(f"Error in get_soil_texture: {e}")
        return None

def get_ndwi(comp, region):
    if comp is None:
        return None
    try:
        img = comp.expression("(B3)/(B3)", {"B3": comp.select("B3"), "B8": comp.select("B8")}).rename("ndwi")
        return safe_get_info(img.reduceRegion(ee.Reducer.mean(), geometry=region, scale=10, maxPixels=1e13).get("ndwi"), "NDWI")
    except Exception as e:
        logging.error(f"Error in get_ndwi: {e}")
        return None

def get_ndvi(comp, region):
    if comp is None:
        return None
    try:
        ndvi = comp.normalizedDifference(["B8", "B4"]).rename("ndvi")
        return safe_get_info(ndvi.reduceRegion(ee.Reducer.mean(), geometry=region, scale=10, maxPixels=1e13).get("ndvi"), "NDVI")
    except Exception as e:
        logging.error(f"Error in get_ndvi: {e}")
        return None

def get_evi(comp, region):
    if comp is None:
        return None
    try:
        evi = comp.expression(
            "2.5 ",
            {"NIR": comp.select("B8"), "RED": comp.select("B4"), "BLUE": comp.select("B2")}
        ).rename("evi")
        return safe_get_info(evi.reduceRegion(ee.Reducer.mean(), geometry=region, scale=10, maxPixels=1e13).get("evi"), "EVI")
    except Exception as e:
        logging.error(f"Error in get_evi: {e}")
        return None

def get_fvc(comp, region):
    if comp is None:
        return None
    try:
        ndvi = comp.normalizedDifference(["B8", "B4"])
        ndvi_min = 0.2
        ndvi_max = 0.8
        fvc = ndvi.subtract(ndvi_min).divide(ndvi_max - ndvi_min).pow(2).clamp(0, 1).rename("fvc")
        return safe_get_info(fvc.reduceRegion(ee.Reducer.mean(), geometry=region, scale=10, maxPixels=1e13).get("fvc"), "FVC")
    except Exception as e:
        logging.error(f"Error in get_fvc: {e}")
        return None

def get_npk_for_region(comp, region):
    if comp is None:
        return None, None, None
    try:
        brightness = comp.expression('(B2 + B3 + B4) / 3', {'B2': comp.select('B2'), 'B3': comp.select('B3'), 'B4': comp.select('B4')})
        salinity2 = comp.expression('(B11 - B8) / (B11 + B8 + 1e-6)', {'B11': comp.select('B11'), 'B8': comp.select('B8')})
        N_est = comp.expression("5 ", {'B2': comp.select('B2'), 'B3': comp.select('B3'), 'B4': comp.select('B4')}).rename('N').clamp(0, 1000)
        P_est = comp.expression("3 ", {'B8': comp.select('B8'), 'B11': comp.select('B11')}).rename('P').clamp(0, 500)
        K_est = comp.expression("5 ", {'brightness': brightness, 'B3': comp.select('B3'), 'salinity2': salinity2}).rename('K').clamp(0, 1000)
        npk_image = N_est.addBands(P_est).addBands(K_est)
        stats = npk_image.reduceRegion(reducer=ee.Reducer.mean(), geometry=region, scale=10, maxPixels=1e9).getInfo()
        n = stats.get('N', None)
        p = stats.get('P', None)
        k = stats.get('K', None)
        if n is not None and (n < 0 or n > 1000):
            logging.warning(f"Unrealistic Nitrogen value: {n}")
            n = None
        if p is not None and (p < 0 or p > 500):
            logging.warning(f"Unrealistic Phosphorus value: {p}")
            p = None
        if k is not None and (k < 0 or k > 1000):
            logging.warning(f"Unrealistic Potassium value: {k}")
            k = None
        return float(n) if n is not None else None, float(p) if p is not None else None, float(k) if k is not None else None
    except Exception as e:
        logging.error(f"Error in get_npk_for_region: {e}")
        return None, None, None
def calculate_soil_health_score(params):
    score = 0
    total_params = len(params)
    for param, value in params.items():
        if value is None:
            total_params -= 1
            continue
        if param == "Soil Texture":
            if value == IDEAL_RANGES[param]:
                score += 1
        else:
            min_val, max_val = IDEAL_RANGES.get(param, (None, None))
            if min_val is None and max_val is not None:
                if value <= max_val:
                    score += 1
            elif max_val is None and min_val is not None:
                if value >= min_val:
                    score += 1
            elif min_val is not None and max_val is not None:
                if min_val <= value <= max_val:
                    score += 1
    percentage = (score / total_params) * 100 if total_params > 0 else 0
    rating = "Excellent" if percentage >= 80 else "Good" if percentage >= 60 else "Fair" if percentage >= 40 else "Poor"
    return percentage, rating

def generate_interpretation(param, value):
    if value is None:
        return "Data unavailable."
    if param == "Soil Texture":
        return TEXTURE_CLASSES.get(value, "Unknown texture.")
    if param == "NDWI":
        if value >= -0.10:
            return "Good moisture; no irrigation needed."
        elif -0.30 <= value < -0.15:
            return "Mild stress; light irrigation soon."
        elif -0.40 <= value < -0.30:
            return "Moderate stress; irrigate in 1–2 days."
        else:
            return "Severe stress; irrigate immediately."
    min_val, max_val = IDEAL_RANGES.get(param, (None, None))
    if min_val is None and max_val is not None:
        return f"Optimal (≤{max_val})." if value <= max_val else f"High (>{max_val})."
    elif max_val is None and min_val is not None:
        return f"Optimal (≥{min_val})." if value >= min_val else f"Low (<{min_val})."
    else:
        range_text = f"{min_val}-{max_val}" if min_val and max_val else "N/A"
        if min_val is not None and max_val is not None and min_val <= value <= max_val:
            return f"Optimal ({range_text})."
        elif min_val is not None and value < min_val:
            return f"Low (<{min_val})."
        elif max_val is not None and value > max_val:
            return f"High (>{max_val})."
        return f"No interpretation for {param}."


def get_color_for_value(param, value):
    if value is None:
        return 'grey'
    if param == "Soil Texture":
        return 'green' if value == IDEAL_RANGES[param] else 'red'
    min_val, max_val = IDEAL_RANGES.get(param, (None, None))
    if min_val is None and max_val is not None:
        if value <= max_val:
            return 'green'
        elif value <= max_val * 1.2:
            return 'yellow'
        else:
            return 'red'
    elif max_val is None and min_val is not None:
        if value >= min_val:
            return 'green'
        elif value >= min_val * 0.8:
            return 'yellow'
        else:
            return 'red'
    elif min_val is not None and max_val is not None:
        if min_val <= value <= max_val:
            return 'green'
        elif value < min_val:
            if value >= min_val * 0.8:
                return 'yellow'
            else:
                return 'red'
        elif value > max_val:
            if param in ["Phosphorus", "Potassium"] and value <= max_val * 1.5:
                return 'yellow'
            elif value <= max_val * 1.2:
                return 'yellow'
            else:
                return 'red'
    return 'blue'
