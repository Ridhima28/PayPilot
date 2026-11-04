"""
Read-only local demo API for PayPilot's seeded
PostgreSQL database.
"""

import os
from uuid import UUID

import psycopg
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from psycopg.rows import dict_row


# Load DATABASE_URL from the .env file.
load_dotenv()


app = FastAPI(
    title="PayPilot Database API",
    version="0.1.0",
)


# The fictional freelancer ID from seed.sql.
#
# Later, we need to get the real owner ID from
# the authenticated user's session.
DEMO_OWNER_ID = UUID(
    "00000000-0000-0000-0000-000000000001"
)


def query(sql, params=(), single=False):
    """
    Connect to PostgreSQL, run a query, and return
    either one row or all rows.
    """

    database_url = os.getenv("DATABASE_URL")

    if not database_url:
        raise HTTPException(
            status_code=500,
            detail="DATABASE_URL is not configured.",
        )

    try:
        with psycopg.connect(
            database_url,
            row_factory=dict_row,
            connect_timeout=5,
        ) as connection:

            with connection.cursor() as cursor:
                cursor.execute(sql, params)

                if single:
                    return cursor.fetchone()

                return cursor.fetchall()

    except psycopg.Error:
        raise HTTPException(
            status_code=503,
            detail=(
                "Database request failed. "
                "Check the connection and schema."
            ),
        )


@app.get("/")
def home():
    """Check that the FastAPI application is running."""

    return {
        "message": "PayPilot Database API is running"
    }


@app.get("/health/db")
def health():
    """Check that FastAPI can connect to PostgreSQL."""

    result = query(
        "SELECT 1 AS result",
        single=True,
    )

    return {
        "database": "connected",
        "test_result": result["result"],
    }


@app.get("/invoices")
def invoices():
    """Return invoices for the fictional demo freelancer."""

    rows = query(
        """
        SELECT
            i.id,
            i.invoice_number,
            c.name AS client_name,
            i.status,
            i.currency,
            i.due_date,
            i.approved_total,

            (
                i.status = 'approved'
                AND i.due_date < CURRENT_DATE
            ) AS overdue

        FROM public.invoices AS i

        JOIN public.clients AS c
            ON c.id = i.client_id
            AND c.owner_id = i.owner_id

        WHERE i.owner_id = %s

        ORDER BY i.invoice_number;
        """,
        (DEMO_OWNER_ID,),
    )

    # Return money as a string to avoid converting
    # decimal amounts to floating-point values.
    for row in rows:
        if row["approved_total"] is not None:
            row["approved_total"] = str(
                row["approved_total"]
            )

    return {
        "invoices": rows
    }


@app.get("/dashboard/summary")
def summary():
    """
    Return outstanding invoice counts and totals,
    grouped by currency.
    """

    rows = query(
        """
        SELECT
            currency,

            COUNT(*) AS outstanding_count,

            SUM(approved_total) AS outstanding_total,

            COUNT(*) FILTER (
                WHERE due_date < CURRENT_DATE
            ) AS overdue_count

        FROM public.invoices

        WHERE owner_id = %s
          AND status = 'approved'

        GROUP BY currency

        ORDER BY currency;
        """,
        (DEMO_OWNER_ID,),
    )

    for row in rows:
        row["outstanding_total"] = str(
            row["outstanding_total"]
        )

    return {
        "summary": rows
    }