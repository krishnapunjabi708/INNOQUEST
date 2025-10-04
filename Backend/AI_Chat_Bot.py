import streamlit as st
import google.generativeai as genai
import os
import time
import logging
from typing import List, Dict, Optional
import io
from PIL import Image
import base64
import json
from datetime import datetime

# --- Configuration Section ---
# Set your Gemini API key here. In a real app, use secrets management (e.g., st.secrets).
API_KEY = "YOUR_GEMINI_API_KEY_HERE"  # Replace with your actual API key
genai.configure(api_key=API_KEY)

# Model configuration
MODEL_NAME = "gemini-1.5-pro-latest"  # Supports multimodal (text + images)
GENERATION_CONFIG = {
    "temperature": 0.7,
    "top_p": 0.95,
    "top_k": 40,
    "max_output_tokens": 2048,  # Increased for more detailed responses
}

# Safety settings
SAFETY_SETTINGS = [
    {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
]

# System prompt (enhanced for advanced behavior)
SYSTEM_PROMPT = """
You are GrokAI, an advanced multimodal AI assistant built by xAI-inspired design. 
You can handle text, images, and complex queries. Be helpful, witty, and insightful like Grok.
Use markdown for formatting: **bold**, *italic*, `code`, lists, tables, etc.
Maintain conversation context. If images are provided, analyze and describe them accurately.
For code requests, provide complete, executable examples with comments.
Respond professionally but with a touch of humor when appropriate.
"""

# Logging setup
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Streamlit App Setup ---
st.set_page_config(
    page_title="Advanced Multimodal Gemini Chatbot",
    page_icon="🤖",
    layout="wide",
    initial_sidebar_state="expanded",
    menu_items={
        'Get Help': 'https://docs.streamlit.io/',
        'Report a bug': 'https://github.com/streamlit/streamlit/issues',
        'About': "# Advanced Gemini Chatbot\nBuilt with Streamlit and Google Gemini API."
    }
)

# Sidebar for advanced settings
with st.sidebar:
    st.title("Advanced Settings")
    
    # Model selection
    model_options = ["gemini-1.5-pro-latest", "gemini-1.0-pro"]
    selected_model = st.selectbox("Select Model", model_options, index=0)
    
    # Generation parameters
    temperature = st.slider("Temperature (Creativity)", 0.0, 1.0, 0.7, 0.05)
    max_tokens = st.slider("Max Output Tokens", 100, 4096, 2048, 100)
    top_p = st.slider("Top P", 0.1, 1.0, 0.95, 0.05)
    
    # Theme selection
    theme = st.selectbox("App Theme", ["Light", "Dark"], index=0)
    if theme == "Dark":
        st.markdown(
            """
            <style>
            .stApp { background-color: #1e1e1e; color: white; }
            </style>
            """,
            unsafe_allow_html=True
        )
    
    st.markdown("---")
    
    # Session management
    if "session_id" not in st.session_state:
        st.session_state.session_id = datetime.now().strftime("%Y%m%d_%H%M%S")
    st.info(f"Session ID: {st.session_state.session_id}")
    
    if st.button("New Session"):
        for key in list(st.session_state.keys()):
            del st.session_state[key]
        st.experimental_rerun()
    
    st.markdown("---")
    st.info("Upload images for analysis. Chat supports multimodal inputs!")

# Initialize session state
if "messages" not in st.session_state:
    st.session_state.messages = []  # Display messages

if "chat_history" not in st.session_state:
    st.session_state.chat_history = []  # Gemini history (parts)

if "model" not in st.session_state or st.session_state.get("selected_model") != selected_model:
    st.session_state.selected_model = selected_model
    GENERATION_CONFIG.update({
        "temperature": temperature,
        "top_p": top_p,
        "max_output_tokens": max_tokens,
    })
    st.session_state.model = genai.GenerativeModel(
        model_name=selected_model,
        generation_config=GENERATION_CONFIG,
        safety_settings=SAFETY_SETTINGS,
        system_instruction=SYSTEM_PROMPT
    )
    logger.info(f"Model initialized: {selected_model}")

# --- Main Chat Interface ---
st.title("🤖 Advanced Multimodal Gemini AI Chatbot")

# Image uploader (multimodal support)
uploaded_file = st.file_uploader("Upload an image for analysis (optional)", type=["jpg", "png", "jpeg", "gif"])

image_part: Optional[Dict] = None
if uploaded_file:
    image = Image.open(uploaded_file)
    st.image(image, caption="Uploaded Image", use_column_width=True)
    
    # Prepare image for Gemini (base64 or bytes)
    img_byte_arr = io.BytesIO()
    image.save(img_byte_arr, format='PNG')
    img_byte_arr = img_byte_arr.getvalue()
    image_part = {
        "mime_type": "image/png",
        "data": img_byte_arr
    }
    logger.info("Image uploaded and prepared for multimodal input.")

# Display chat history with images
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        if "image" in message:
            st.image(base64.b64decode(message["image"]), caption="Image Response")
        st.markdown(message["content"])

# User input
user_input = st.chat_input("Type your message or ask about the image...")

if user_input:
    # Prepare content: text + optional image
    content = [user_input]
    if image_part:
        content.insert(0, image_part)  # Image first for analysis
    
    # Add to display and history
    display_msg = {"role": "user", "content": user_input}
    if image_part:
        display_msg["image"] = base64.b64encode(image_part["data"]).decode('utf-8')
    st.session_state.messages.append(display_msg)
    
    with st.chat_message("user"):
        if image_part:
            st.image(image_part["data"], caption="User Uploaded Image")
        st.markdown(user_input)
    
    # Generate response with streaming
    with st.chat_message("assistant"):
        message_placeholder = st.empty()
        full_response = ""
        
        try:
            # Start chat with history
            chat_session = st.session_state.model.start_chat(history=st.session_state.chat_history)
            
            # Send multimodal content
            response_stream = chat_session.send_message(content, stream=True)
            
            for chunk in response_stream:
                if chunk.text:
                    full_response += chunk.text
                    message_placeholder.markdown(full_response + "▌")
                time.sleep(0.01)
            
            message_placeholder.markdown(full_response)
            
            # Update histories
            st.session_state.messages.append({"role": "assistant", "content": full_response})
            st.session_state.chat_history.append({"role": "user", "parts": content})
            st.session_state.chat_history.append({"role": "model", "parts": [full_response]})
            
            logger.info("Response generated successfully.")
        
        except Exception as e:
            error_msg = f"Error: {str(e)}"
            st.error(error_msg)
            st.session_state.messages.append({"role": "assistant", "content": error_msg})
            logger.error(error_msg)

# --- Advanced Features ---
# Conversation summary
if st.sidebar.button("Summarize Conversation"):
    if st.session_state.chat_history:
        summary_prompt = "Summarize this conversation concisely:\n" + json.dumps(st.session_state.chat_history, default=str)
        try:
            summary = st.session_state.model.generate_content(summary_prompt).text
            st.sidebar.markdown("### Summary")
            st.sidebar.write(summary)
            logger.info("Conversation summarized.")
        except Exception as e:
            st.sidebar.error(f"Error: {str(e)}")
    else:
        st.sidebar.info("No conversation yet.")

# Export chat as JSON or Markdown
if st.sidebar.button("Export Chat"):
    if st.session_state.messages:
        # Markdown export
        md_export = "# Chat History\n\n" + "\n\n".join([f"**{msg['role'].capitalize()}:** {msg['content']}" for msg in st.session_state.messages])
        st.sidebar.download_button("Download Markdown", md_export, "chat_history.md", "text/markdown")
        
        # JSON export
        json_export = json.dumps(st.session_state.messages, default=str)
        st.sidebar.download_button("Download JSON", json_export, "chat_history.json", "application/json")
        
        logger.info("Chat exported.")
    else:
        st.sidebar.info("No history to export.")

# Token usage estimate (advanced approximation)
if st.session_state.messages:
    total_tokens = sum(len(msg["content"].split()) for msg in st.session_state.messages if "content" in msg) * 1.3  # Approx words to tokens
    if any("image" in msg for msg in st.session_state.messages):
        total_tokens += 1000  # Rough estimate for images
    st.caption(f"Approx. tokens used: {int(total_tokens)}")

# Feedback mechanism
feedback = st.selectbox("Rate this response", ["", "👍 Great", "👎 Poor", "🆗 Okay"])
if feedback:
    logger.info(f"User feedback: {feedback}")
    st.success("Thanks for your feedback!")

# --- Helper Functions ---
def reset_app():
    """Reset the entire app state."""
    for key in list(st.session_state.keys()):
        del st.session_state[key]
    st.experimental_rerun()

if st.button("Reset App"):
    reset_app()

# --- End of App ---
st.markdown("---")
st.caption("Powered by Google Gemini API (Multimodal) and Streamlit. Secure API keys in production. Log level: INFO.")