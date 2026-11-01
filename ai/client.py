
import os
from dotenv import load_dotenv
from groq import Groq

# Load environment variables from .env
load_dotenv()

# Initialize Groq client
client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def ask_llm(message: str) -> str:
    response = client.chat.completions.create(
        model=os.getenv("GROQ_MODEL"),
        messages=[
            {
                "role": "system",
                "content": "You are PayPilot AI, an invoice assistant."
            },
            {
                "role": "user",
                "content": message
            }
        ],
        max_completion_tokens=250
    )

    return response.choices[0].message.content or ""

if __name__ == "__main__":
    result = ask_llm(
        "Explain what an invoice is in one simple sentence."
    )
    print("PayPilot AI:", result)
