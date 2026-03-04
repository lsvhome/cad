import requests
import os
from openai import OpenAI

class LLMClient:
    """Unified client for both cloud AI (OpenAI) and local AI (Ollama)"""
    
    def __init__(self, config):
        self.config = config
        self.provider = config.ai_provider
        
        if self.provider == "openai":
            self.client = OpenAI(api_key=config.openai_api_key)
            self.model = config.openai_model
        elif self.provider == "ollama":
            self.base_url = config.ollama_base_url
            self.model = config.ollama_model
        else:
            raise ValueError(f"Unknown AI provider: {self.provider}")
    
    def get_completion(self, system_prompt, user_prompt):
        """Get completion from LLM"""
        if self.provider == "openai":
            return self._get_openai_completion(system_prompt, user_prompt)
        elif self.provider == "ollama":
            return self._get_ollama_completion(system_prompt, user_prompt)
    
    def _get_openai_completion(self, system_prompt, user_prompt):
        """Get completion from OpenAI API"""
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=0.7,
                max_tokens=2000
            )
            return response.choices[0].message.content
        except Exception as e:
            print(f"OpenAI API error: {e}")
            raise
    
    def _get_ollama_completion(self, system_prompt, user_prompt):
        """Get completion from Ollama API"""
        try:
            url = f"{self.base_url}/api/chat"
            payload = {
                "model": self.model,
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "num_predict": 2000
                }
            }
            
            response = requests.post(url, json=payload, timeout=120)
            response.raise_for_status()
            
            result = response.json()
            return result["message"]["content"]
            
        except requests.exceptions.RequestException as e:
            print(f"Ollama API error: {e}")
            raise
