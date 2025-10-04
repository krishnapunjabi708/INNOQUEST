import streamlit as st
import google.generativeai as genai
import os
import time
from typing import List, Dict

# --- Configuration Section ---
# Set your Gemini API key here. In a real app, use secrets management.
API_KEY = "YOUR_GEMINI_API_KEY_HERE"  # Replace with your actual API key
genai.configure(api_key=API_KEY)

# Model configuration
MODEL_NAME = "gemini-1.5-pro-latest"  # You can change to other models like "gemini-1.0-pro"
GENERATION_CONFIG = {
    "temperature": 0.7,  # Controls randomness: higher = more creative
    "top_p": 0.95,       # Nucleus sampling
    "top_k": 40,         # Top-k sampling
    "max_output_tokens": 1024,  # Max tokens in response
}

# Safety settings to prevent harmful content
SAFETY_SETTINGS = [
    {
        "category": "HARM_CATEGORY_HARASSMENT",
        "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
    {
        "category": "HARM_CATEGORY_HATE_SPEECH",
        "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
    {
        "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
    {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
]

# System prompt for the chatbot (customize this for personality/behavior)
SYSTEM_PROMPT = """
You are an advanced AI chatbot named GrokAI, built to assist users with a wide range of tasks. 
Be helpful, informative, and engaging. Use markdown for formatting responses when appropriate.
Maintain context from previous messages in the conversation.
If the user asks about code, provide well-commented examples.
Always respond in a friendly and professional manner.
"""

# --- Streamlit App Setup ---
st.set_page_config(
    page_title="Advanced Gemini Chatbot",
    page_icon="🤖",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Sidebar for settings
with st.sidebar:
    st.title("Chatbot Settings")
    temperature = st.slider("Temperature (Creativity)", min_value=0.0, max_value=1.0, value=0.7, step=0.1)
    max_tokens = st.slider("Max Output Tokens", min_value=100, max_value=2048, value=1024, step=100)
    st.markdown("---")
    st.info("This is an advanced chatbot using Google's Gemini API. Enter your message below to start chatting!")
    if st.button("Clear Chat History"):
        st.session_state.messages = []
        st.session_state.chat_history = []
        st.success("Chat history cleared!")

# Initialize session state
if "messages" not in st.session_state:
    st.session_state.messages = []  # For display in chat UI

if "chat_history" not in st.session_state:
    st.session_state.chat_history = []  # For Gemini conversation history

if "model" not in st.session_state:
    # Initialize the Gemini model
    st.session_state.model = genai.GenerativeModel(
        model_name=MODEL_NAME,
        generation_config=GENERATION_CONFIG,
        safety_settings=SAFETY_SETTINGS,
        system_instruction=SYSTEM_PROMPT
    )

# --- Main Chat Interface ---
st.title("🤖 Advanced Gemini AI Chatbot on Streamlit")

# Display chat history
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# User input
user_input = st.chat_input("Type your message here...")

if user_input:
    # Add user message to display and history
    st.session_state.messages.append({"role": "user", "content": user_input})
    st.session_state.chat_history.append({"role": "user", "parts": [user_input]})
    
    with st.chat_message("user"):
        st.markdown(user_input)
    
    # Generate response with streaming
    with st.chat_message("assistant"):
        message_placeholder = st.empty()
        full_response = ""
        
        try:
            # Start chat session with history
            chat_session = st.session_state.model.start_chat(history=st.session_state.chat_history)
            
            # Generate content stream
            response_stream = chat_session.send_message(user_input, stream=True)
            
            for chunk in response_stream:
                if chunk.text:
                    full_response += chunk.text
                    message_placeholder.markdown(full_response + "▌")  # Streaming effect
                time.sleep(0.01)  # Small delay for smooth streaming
            
            # Finalize response
            message_placeholder.markdown(full_response)
            
            # Add to histories
            st.session_state.messages.append({"role": "assistant", "content": full_response})
            st.session_state.chat_history.append({"role": "model", "parts": [full_response]})
        
        except Exception as e:
            error_msg = f"Error generating response: {str(e)}"
            st.error(error_msg)
            st.session_state.messages.append({"role": "assistant", "content": error_msg})

# --- Additional Advanced Features ---
# Conversation summary (optional, can be triggered)
if st.sidebar.button("Summarize Conversation"):
    if st.session_state.chat_history:
        summary_prompt = "Summarize the following conversation:\n" + "\n".join([f"{msg['role']}: {msg['parts'][0]}" for msg in st.session_state.chat_history])
        try:
            summary_response = st.session_state.model.generate_content(summary_prompt)
            st.sidebar.markdown("### Conversation Summary")
            st.sidebar.write(summary_response.text)
        except Exception as e:
            st.sidebar.error(f"Error summarizing: {str(e)}")
    else:
        st.sidebar.info("No conversation to summarize yet.")

# Export chat history
if st.sidebar.button("Export Chat History"):
    if st.session_state.messages:
        chat_export = "\n\n".join([f"**{msg['role'].capitalize()}:** {msg['content']}" for msg in st.session_state.messages])
        st.sidebar.download_button(
            label="Download Chat as Markdown",
            data=chat_export,
            file_name="gemini_chat_history.md",
            mime="text/markdown"
        )
    else:
        st.sidebar.info("No chat history to export.")

# --- Helper Functions (Advanced) ---
def reset_conversation():
    """Reset the conversation history."""
    st.session_state.messages = []
    st.session_state.chat_history = []
    st.experimental_rerun()

# Add a reset button in main area for convenience
if st.button("Reset Conversation"):
    reset_conversation()

# Display token usage estimate (approximate, since Gemini doesn't provide exact counts easily)
if st.session_state.messages:
    total_tokens_approx = sum(len(msg["content"].split()) for msg in st.session_state.messages) * 1.3  # Rough estimate
    st.caption(f"Approximate tokens used in this session: {int(total_tokens_approx)}")

# --- End of App ---
st.markdown("---")
st.caption("Powered by Google Gemini API and Streamlit. Note: This is a demo; handle API keys securely in production.")