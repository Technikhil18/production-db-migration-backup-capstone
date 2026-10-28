-- Migration 003 UP: standard reporting view
BEGIN;

CREATE OR REPLACE VIEW capstone.customer_order_summary AS
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(o.order_id) AS total_orders,
    COUNT(o.order_id) FILTER (WHERE o.order_status = 'paid') AS paid_orders,
    COALESCE(SUM(o.total_amount) FILTER (WHERE o.order_status IN ('paid', 'shipped')), 0)::NUMERIC(14,2)
        AS recognized_revenue,
    MAX(o.created_at) AS latest_order_at
FROM capstone.customers AS c
LEFT JOIN capstone.orders AS o
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.email;

COMMIT;
