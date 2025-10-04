import gemini
from gemini import ChatCompletion
from Backend.API_Keys import GEMINI_API_KEY
from Backend.AI_Chat_Bot_Interface import AI_Chat_Bot_Interface
from Backend.Message import Message
from Backend.Conversation import Conversation

class GeminiChatBot(AI_Chat_Bot_Interface):
    def __init__(self):
        self.api_key = GEMINI_API
        gemini.api_key = self.api_key
        self.model = "gemini-1.5-pro"
        self.chat_completion = ChatCompletion(model=self.model)
        self.conversation = Conversation()
        self.system_message = Message("system", "You are a helpful assistant.")
        self.conversation.add_message(self.system_message)
        self.max_history = 10  # Limit the number of messages in history
        self.temperature = 0.7  # Default temperature for response generation
        self.top_p = 0.9  # Default top_p for response generation
        self.max_tokens = 150  # Default max tokens for response generation
        self.presence_penalty = 0.0  # Default presence penalty
        self.frequency_penalty = 0.0  # Default frequency penalty
        self.stop_sequences = None  # Default stop sequences
        self.response = None
        self.error = None
        self.last_user_message = None
        self.last_bot_message = None
        