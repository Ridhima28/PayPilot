-- Example 1: List one freelancer's invoices.
--
-- This uses the fictional demo owner's ID.
-- In the real app, the backend must obtain the owner ID
-- from the authenticated session.

SELECT
    i.invoice_number,
    c.name AS client,
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

WHERE i.owner_id =
    '00000000-0000-0000-0000-000000000001'

ORDER BY i.created_at DESC;


-- Example 2: Calculate outstanding totals by currency.
--
-- Only approved, unpaid invoices are counted.
-- Different currencies are displayed separately.

SELECT
    currency,

    COUNT(*) AS outstanding_count,

    SUM(approved_total) AS outstanding_total,

    COUNT(*) FILTER (
        WHERE due_date < CURRENT_DATE
    ) AS overdue_count

FROM public.invoices

WHERE owner_id =
    '00000000-0000-0000-0000-000000000001'

    AND status = 'approved'

GROUP BY currency;