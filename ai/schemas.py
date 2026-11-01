
from datetime import date
from decimal import Decimal

from pydantic import BaseModel, Field, field_validator


class InvoiceData(BaseModel):
    customer_name: str | None = None
    customer_email: str | None = None

    amount: Decimal | None = Field(
        default=None,
        gt=0
    )

    currency: str | None = None
    description: str | None = None
    due_date: date | None = None

    @field_validator("currency")
    @classmethod
    def validate_currency(cls, value):
        if value is None:
            return None

        supported = {"USD", "EUR", "GBP"}

        if value not in supported:
            raise ValueError(
                f"Unsupported currency: {value}"
            )

        return value
