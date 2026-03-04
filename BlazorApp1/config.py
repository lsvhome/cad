import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Configuration for LLM client"""
    
    def __init__(self):
        # AI Provider: 'openai' or 'ollama'
        self.ai_provider = os.getenv("AI_PROVIDER", "openai").lower()
        
        # OpenAI Configuration
        self.openai_api_key = os.getenv("OPENAI_API_KEY", "")
        self.openai_model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
        
        # Ollama Configuration
        self.ollama_base_url = os.getenv("OLLAMA_BASE_URL", "http://host.docker.internal:11434")
        self.ollama_model = os.getenv("OLLAMA_MODEL", "llama3.2")
        
        self._validate()
    
    def _validate(self):
        """Validate configuration"""
        if self.ai_provider == "openai" and not self.openai_api_key:
            raise ValueError("OPENAI_API_KEY is required when using OpenAI provider")
        elif self.ai_provider not in ["openai", "ollama"]:
            raise ValueError(f"Invalid AI_PROVIDER: {self.ai_provider}. Must be 'openai' or 'ollama'")
