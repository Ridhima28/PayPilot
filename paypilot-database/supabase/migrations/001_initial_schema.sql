-- PayPilot MVP database schema
--
-- Requires PostgreSQL 15 or later.
-- Supabase authentication and access policies are separate work.

BEGIN;


CREATE TABLE public.profiles (
    id UUID PRIMARY KEY,

    display_name TEXT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


CREATE TABLE public.clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    owner_id UUID NOT NULL
        REFERENCES public.profiles(id),

    name TEXT NOT NULL,

    email TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Allows invoices to verify that a client belongs
    -- to the same owner as the invoice.
    UNIQUE (id, owner_id)
);


-- An invoice created by a freelancer.
CREATE TABLE public.invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    owner_id UUID NOT NULL
        REFERENCES public.profiles(id),

    client_id UUID NOT NULL,

    invoice_number TEXT NOT NULL,

    currency TEXT NOT NULL
        CHECK (currency ~ '^[A-Z]{3}$'),

    due_date DATE,

    status TEXT NOT NULL DEFAULT 'draft'
        CHECK (
            status IN (
                'draft',
                'approved',
                'paid',
                'cancelled'
            )
        ),

    -- The amount approved for payment.
    -- Draft invoices do not need an approved total yet.
    approved_total NUMERIC(12, 2)
        CHECK (approved_total >= 0),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Prevents an invoice from referencing another
    -- freelancer's client.
    FOREIGN KEY (client_id, owner_id)
        REFERENCES public.clients(id, owner_id),

    -- An invoice number must be unique for each freelancer.
    UNIQUE (owner_id, invoice_number),

    -- Approved and paid invoices need a due date and total.
    CHECK (
        status IN ('draft', 'cancelled')
        OR (
            due_date IS NOT NULL
            AND approved_total IS NOT NULL
        )
    )
);


-- Individual charges on an invoice.
CREATE TABLE public.invoice_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    invoice_id UUID NOT NULL
        REFERENCES public.invoices(id)
        ON DELETE CASCADE,

    description TEXT NOT NULL,

    quantity NUMERIC(12, 2) NOT NULL
        CHECK (quantity > 0),

    unit_price NUMERIC(12, 2) NOT NULL
        CHECK (unit_price >= 0)
);


-- A payment attempt is separate from the invoice itself.
-- An invoice may have a failed attempt and a later
-- successful attempt.
CREATE TABLE public.payment_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    invoice_id UUID NOT NULL
        REFERENCES public.invoices(id),

    paypal_order_id TEXT UNIQUE,

    paypal_capture_id TEXT UNIQUE,

    amount NUMERIC(12, 2) NOT NULL
        CHECK (amount >= 0),

    currency TEXT NOT NULL
        CHECK (currency ~ '^[A-Z]{3}$'),

    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'completed',
                'failed'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- Indexes help common dashboard queries.
CREATE INDEX invoices_owner_status_idx
    ON public.invoices(owner_id, status);

CREATE INDEX invoice_items_invoice_idx
    ON public.invoice_items(invoice_id);

CREATE INDEX payment_attempts_invoice_idx
    ON public.payment_attempts(invoice_id);


-- Enable row-level security.
ALTER TABLE public.profiles
    ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.clients
    ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.invoices
    ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.invoice_items
    ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.payment_attempts
    ENABLE ROW LEVEL SECURITY;

COMMIT;