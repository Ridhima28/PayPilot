
import json
import os

from groq import Groq
from dotenv import load_dotenv
from ai.schemas import InvoiceData
from ai.prompts import INVOICE_EXTRACTION_PROMPT

load_dotenv()

client = Groq(api_key=os.getenv("GROQ_API_KEY"))


def extract_invoice(message: str) -> dict:
    response = client.chat.completions.create(
        model=os.getenv("GROQ_MODEL"),
        messages=[
            {
                "role": "system",
                "content": INVOICE_EXTRACTION_PROMPT,
            },
            {
                "role": "user",
                "content": message,
            },
        ],
        response_format={"type": "json_object"},
        max_completion_tokens=600,
    )

    content = response.choices[0].message.content

    if not content:
        raise ValueError("The model returned an empty response.")

    return InvoiceData.model_validate_json(content)


if __name__ == "__main__":
    example = (
        "Create an invoice for John Smith for $500 "
        "for website development, due November 15, 2026."
    )

    invoice = extract_invoice(example)

    print(invoice.model_dump_json(indent=2))
