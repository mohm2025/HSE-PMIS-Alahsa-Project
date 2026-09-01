"""Configuration for the LLM Council.

Models are hardcoded here. The chairman may be the same as, or different from,
the council members. Default chairman is Gemini per project preference.
"""
import os
from dotenv import load_dotenv

load_dotenv()

# OpenRouter API key, read from the .env file in the project root.
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "")

# OpenRouter base URL.
OPENROUTER_BASE_URL = os.getenv(
    "OPENROUTER_BASE_URL", "https://openrouter.ai/api/v1"
)

# Council members — each model produces a Stage 1 response and a Stage 2 ranking.
COUNCIL_MODELS = [
    "openai/gpt-5.1",
    "anthropic/claude-opus-4.1",
    "google/gemini-2.5-pro",
    "x-ai/grok-4",
]

# Chairman — synthesizes the final answer in Stage 3.
CHAIRMAN_MODEL = "google/gemini-2.5-pro"

# Request tuning.
REQUEST_TIMEOUT = float(os.getenv("OPENROUTER_TIMEOUT", "120"))
MAX_TOKENS = int(os.getenv("OPENROUTER_MAX_TOKENS", "4000"))

# Backend port — 8001 to avoid clashing with apps on 8000.
PORT = int(os.getenv("PORT", "8001"))

# Optional attribution headers recommended by OpenRouter.
APP_TITLE = os.getenv("APP_TITLE", "LLM Council")
APP_URL = os.getenv("APP_URL", "http://localhost:5173")
