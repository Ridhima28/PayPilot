-- Fictional data for local development only.
-- This runs automatically the first time Docker initializes
-- the database.

BEGIN;

INSERT INTO public.profiles (
    id,
    display_name
)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Maya Chen'
);


INSERT INTO public.clients (
    id,
    owner_id,
    name,
    email
)
VALUES (
    '10000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Sunrise Cafe',
    'cafe@example.com'
);


INSERT INTO public.invoices (
    id,
    owner_id,
    client_id,
    invoice_number,
    currency,
    due_date,
    status,
    approved_total
)
VALUES
    (
        '20000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        'INV-001',
        'USD',
        CURRENT_DATE + 14,
        'approved',
        500.00
    ),

    (
        '20000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        'INV-002',
        'USD',
        CURRENT_DATE - 7,
        'approved',
        100.00
    ),

    (
        '20000000-0000-0000-0000-000000000003',
        '00000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        'INV-003',
        'USD',
        NULL,
        'draft',
        NULL
    ),

    (
        '20000000-0000-0000-0000-000000000004',
        '00000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        'INV-004',
        'USD',
        CURRENT_DATE - 3,
        'paid',
        200.00
    );


INSERT INTO public.invoice_items (
    invoice_id,
    description,
    quantity,
    unit_price
)
VALUES
    (
        '20000000-0000-0000-0000-000000000001',
        'Homepage design',
        10,
        50.00
    ),

    (
        '20000000-0000-0000-0000-000000000002',
        'Content updates',
        2,
        50.00
    ),

    (
        '20000000-0000-0000-0000-000000000003',
        'Consultation',
        1,
        75.00
    ),

    (
        '20000000-0000-0000-0000-000000000004',
        'Logo design',
        4,
        50.00
    );


-- This is a fictional record, not a real PayPal payment.
INSERT INTO public.payment_attempts (
    invoice_id,
    paypal_order_id,
    paypal_capture_id,
    amount,
    currency,
    status
)
VALUES (
    '20000000-0000-0000-0000-000000000004',
    'DEMO-ORDER-001',
    'DEMO-CAPTURE-001',
    200.00,
    'USD',
    'completed'
);

COMMIT;