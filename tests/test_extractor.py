
import pytest
from pydantic import ValidationError

from ai.schemas import InvoiceData


def test_valid_invoice():
    invoice = InvoiceData(
        customer_name="John Smith",
        amount="500.00",
        currency="USD",
        due_date="2026-11-15"
    )

    assert invoice.customer_name == "John Smith"
    assert str(invoice.amount) == "500.00"


def test_negative_amount():
    with pytest.raises(ValidationError):
        InvoiceData(
            customer_name="John",
            amount="-500",
            currency="USD"
        )


def test_invalid_currency():
    with pytest.raises(ValidationError):
        InvoiceData(
            amount="500",
            currency="HELLO"
        )


def test_invalid_date():
    with pytest.raises(ValidationError):
        InvoiceData(
            amount="500",
            currency="USD",
            due_date="2026-99-99"
        )


def test_missing_information():
    invoice = InvoiceData(
        customer_name="John",
        amount="500"
    )

    assert invoice.customer_email is None
    assert invoice.due_date is None
