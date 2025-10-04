# Project FarmMatrix

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Flutter-blue)](https://flutter.dev)
[![Backend](https://img.shields.io/badge/backend-FastAPI-green)](https://fastapi.tiangolo.com)
[![Data Source](https://img.shields.io/badge/data-Google%20Earth%20Engine-orange)](https://earthengine.google.com)

> **Zone-wise farming recommendations powered by satellite intelligence—no sensors required.**

## 👥 Team Information

**Team Name:** TEAM INORA

**Team Members:**
- **Krishna Punjabi** - Team Leader | Satellite Data & ML Feature Development an Documentation
- **Radhika Kapale** - Flutter Developer | Application Development Specialist
- **Rituja Malode** - Data Base and Connectivity Specialist
- **Rushikesh Patil** - ML and Field Coordinator | Web Development
- **Ishan Pantawane** - UI/UX and Web Development Specialist

**Project Name:** Project FarmMatrix

## 📋 Project Abstract

FarmMatrix is an innovative AI-driven platform that leverages satellite imagery to generate comprehensive soil health reports and deliver actionable, zone-level farming insights without the need for physical sensors or costly laboratory testing. The system addresses critical challenges faced by small farmers worldwide, particularly in rural India, by providing instant, affordable soil analysis using satellite data from Sentinel-2, MODIS, and SMAP sources.

The platform automatically divides agricultural fields into 3-5 management zones based on soil health parameters derived from vegetation indices (NDVI), water content analysis (NDWI), and surface temperature mapping (LST). Each zone receives customized recommendations for irrigation, fertilization, and soil amendments, enabling precision agriculture that maximizes crop yield while minimizing resource waste and environmental impact.

Key innovations include sensor-free soil parameter inference, real-time satellite data processing through Google Earth Engine, AI-powered zone mapping with unsupervised machine learning clustering, and a farmer-friendly mobile application supporting multiple local languages with offline functionality. The solution operates at an estimated cost of ₹75-₹100 (~$1 USD) per report, making precision agriculture accessible to smallholder farmers globally.

## 🛠️ Tech Stack

### Backend
- **FastAPI** - High-performance web framework for API development
- **Python** - Core programming language for data processing and AI models
- **Google Earth Engine** - Satellite imagery processing and analysis
- **NumPy & Pandas** - Data manipulation and numerical computing
- **Scikit-learn** - Machine learning algorithms for clustering and analysis
- **OpenCV** - Image processing and computer vision
- **GeoPandas** - Geospatial data analysis
- **Rasterio** - Raster data I/O and processing

### Frontend
- **JavaScript/TypeScript** - Frontend programming languages
- **Material-UI** - Component library for responsive design
- **Leaflet.js** - Interactive mapping library
- **Chart.js** - Data visualization and charting
- **Axios** - HTTP client for API communication

### Mobile Application
- **Flutter** - Cross-platform mobile app development framework
- **Dart** - Programming language for Flutter development
- **Flutter Maps** - Interactive mapping for mobile
- **Provider** - State management for Flutter
- **HTTP** - API communication for mobile app
- **PDF** - Report generation and offline storage

### Database & Storage
- **PostgreSQL** - Primary database for user data and reports
- **Redis** - Caching and session management
- **Google Cloud Storage** - File storage for reports and images
- **SQLite** - Local storage for mobile offline functionality

### DevOps & Deployment
- **Docker** - Containerization for deployment
- **Google Cloud Platform** - Cloud infrastructure
- **GitHub Actions** - CI/CD pipeline
- **Nginx** - Web server and reverse proxy

### AI/ML & Data Processing
- **TensorFlow** - Deep learning framework for advanced AI models
- **Keras** - High-level neural network API
- **GDAL** - Geospatial data processing library
- **Matplotlib** - Data visualization for analysis
- **Seaborn** - Statistical data visualization

## 📊 Datasets Used

### Primary Satellite Data Sources
1. **Sentinel-2 (ESA)**
   - **Description:** High-resolution optical imagery with 13 spectral bands
   - **Resolution:** 10-60m spatial resolution, 5-day revisit time
   - **Usage:** NDVI, NDWI, SAVI, EVI calculation for vegetation and moisture analysis
   - **Access:** Free via Google Earth Engine API

2. **MODIS (NASA)**
   - **Description:** Moderate Resolution Imaging Spectroradiometer data
   - **Resolution:** 250m-1km spatial resolution, daily coverage
   - **Usage:** Land Surface Temperature (LST) analysis and thermal monitoring
   - **Access:** Free via Google Earth Engine API

3. **SMAP (NASA)**
   - **Description:** Soil Moisture Active Passive satellite data
   - **Resolution:** 36km spatial resolution, 2-3 day revisit
   - **Usage:** Soil moisture content estimation and validation
   - **Access:** Free via Google Earth Engine API

### Supporting Datasets
4. **SoilGrids (ISRIC)**
   - **Description:** Global soil property maps at 250m resolution
   - **Usage:** Baseline soil pH, texture, and nutrient reference data
   - **Access:** Open access via ISRIC data portal

5. **CHIRPS (Climate Hazards Group)**
   - **Description:** Climate Hazards Group InfraRed Precipitation with Station data
   - **Resolution:** 0.05° spatial resolution, daily/monthly data
   - **Usage:** Rainfall pattern analysis and irrigation planning
   - **Access:** Free via Google Earth Engine API

6. **SRTM (NASA)**
   - **Description:** Shuttle Radar Topography Mission elevation data
   - **Resolution:** 30m spatial resolution
   - **Usage:** Digital Elevation Model for slope and drainage analysis
   - **Access:** Free via Google Earth Engine API

### Ground Truth & Validation Data
7. **India Soil Health Card Data**
   - **Description:** Government soil testing program data
   - **Usage:** Model validation and calibration for Indian conditions
   - **Access:** Public data via Government of India portals

8. **FAO Soil Database**
   - **Description:** Food and Agriculture Organization global soil data
   - **Usage:** Cross-validation and global model adaptation
   - **Access:** Open access via FAO data portal

### Weather & Climate Data
9. **ERA5 Reanalysis (ECMWF)**
   - **Description:** Fifth generation atmospheric reanalysis data
   - **Usage:** Weather pattern analysis and crop stress prediction
   - **Access:** Free via Google Earth Engine API

10. **NDVI Time Series Data**
    - **Description:** Historical vegetation index data (2000-present)
    - **Usage:** Seasonal trend analysis and crop health monitoring
    - **Source:** Processed from Landsat and MODIS archives

All datasets are processed and analyzed using Google Earth Engine's cloud computing platform, ensuring scalable and real-time processing capabilities. The combination of these diverse data sources enables comprehensive soil health assessment without requiring physical soil sampling or ground-based sensors.

## 🌾 Problem Statement

Small farmers worldwide, especially in rural India, face critical challenges:

- **No accessible soil testing**: Labs are far away, tests cost ₹300-₹500, and results take weeks
- **Resource waste**: Uniform treatment across fields leads to 40% of farming costs in wasted water and fertilizer
- **Environmental damage**: Runoff pollutes water bodies and depletes groundwater
- **Hidden field variations**: Soil differences within fields cause 20-30% yield loss
- **Climate unpredictability**: Changing weather patterns require adaptive farming strategies
- **Technology barriers**: Expensive sensors and complex platforms exclude small farmers

## 🚀 Solution Overview

FarmMatrix eliminates these barriers by providing:

### ✨ Key Features

- **🛰️ Satellite-Only Intelligence**: No ground sensors or lab tests required
- **🤖 AI-Powered Zone Mapping**: Automatic field division into 3-5 management zones
- **📱 Farmer-Friendly Mobile App**: Simple boundary drawing, local language support
- **📊 Instant Reports**: Customized soil health reports in minutes
- **🌐 Offline Capability**: PDF reports accessible without internet
- **💡 Actionable Insights**: Specific fertilizer, irrigation, and soil amendment recommendations

## 🏗️ Project Architecture

### Repository Structure
```
FarmMatrix/
├── Backend/                 # FastAPI server and AI models
│   ├── ai_dashboard.py     # Soil analysis and recommendations
│   ├── Dashboard.py        # Main dashboard backend
│   └── fertility_map.py    # Zone mapping algorithms
├── Frontend/               # React web application
│   └── farmmatrix/        # Frontend components and pages
├── android/               # Flutter mobile application
│   ├── app/              # Android app configuration
│   ├── gradle/           # Build configuration
│   └── lib/             # Flutter source code
├── assets/               # Static assets and resources
├── linux/               # Linux-specific configurations
└── README.md            # Project documentation
```

## 🔧 Getting Started

### Prerequisites
- **Flutter SDK** (≥3.0.0)
- **Node.js** (≥18.0.0)
- **Python** (≥3.8)
- **Google Earth Engine** account
- **Android Studio** (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/team-inora/farmmatrix.git
   cd farmmatrix
   ```

2. **Backend Setup**
   ```bash
   cd Backend
   pip install -r requirements.txt
   uvicorn main:app --reload
   ```

3. **Frontend Setup**
   ```bash
   cd Frontend/farmmatrix
   npm install
   npm start
   ```

4. **Mobile App Setup**
   ```bash
   cd android
   flutter pub get
   flutter run
   ```

### Configuration

1. **Google Earth Engine Setup**
   - Obtain GEE API credentials
   - Configure authentication in backend service

2. **Environment Variables**
   ```bash
   # Create .env file in Backend directory
   GEE_SERVICE_ACCOUNT_KEY=path/to/your/service-account.json
   API_SECRET_KEY=your-secret-key
   ```

## 📈 Key Achievements & Innovation

- **💰 Cost-Effective Solution**: ₹75-₹100 per report vs ₹300-₹500 traditional testing
- **⚡ Rapid Processing**: Minutes vs weeks for conventional soil analysis
- **🌍 Global Scalability**: Works worldwide without infrastructure requirements
- **🌱 Environmental Impact**: Reduces water and fertilizer waste by up to 40%
- **🎯 Precision Agriculture**: Zone-wise recommendations for optimal resource utilization

## 💡 Technical Innovation

### Sensor-Free Soil Analysis
FarmMatrix revolutionizes soil health assessment by eliminating the need for:
- Physical soil sampling
- Expensive IoT sensors  
- Laboratory testing infrastructure
- Ground-based measurement equipment

### AI-Powered Zone Mapping
Advanced machine learning algorithms automatically:
- Divide fields into 3-5 management zones
- Identify soil health variations within fields
- Generate zone-specific farming recommendations
- Adapt to seasonal changes and crop patterns

### Real-Time Satellite Processing
Cloud-native processing pipeline provides:
- Instant access to multi-temporal satellite data
- Automated cloud removal and atmospheric correction
- Real-time index calculation (NDVI, NDWI, LST)
- Continuous field monitoring and updates

## 🌾 Impact & Sustainability

### Economic Benefits
- **Reduced Input Costs**: Optimized fertilizer and water usage
- **Increased Yields**: Precision agriculture techniques improve crop productivity
- **Accessible Technology**: Affordable solution for smallholder farmers
- **Scalable Business Model**: Sustainable through government partnerships and NGO programs

### Environmental Benefits  
- **Water Conservation**: Targeted irrigation reduces water waste
- **Pollution Reduction**: Minimized fertilizer runoff protects water bodies
- **Soil Health**: Long-term monitoring promotes sustainable farming practices
- **Climate Adaptation**: Helps farmers adapt to changing weather patterns
