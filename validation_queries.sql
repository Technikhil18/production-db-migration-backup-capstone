-- Validation queries for the capstone. Run after applying migrations/procedure.

-- 1) Create a test customer.
INSERT INTO capstone.customers (full_name, email)
VALUES ('Demo Customer', 'demo.customer@example.test')
ON CONFLICT (email) DO NOTHING;

-- 2) Create an order through the stored procedure.
-- PostgreSQL requires NULL as the placeholder for an OUT argument in CALL.
CALL capstone.create_order(
    (SELECT customer_id FROM capstone.customers WHERE email = 'demo.customer@example.test'),
    1499.00,
    NULL
);

-- 3) Check standard view.
SELECT * FROM capstone.customer_order_summary
WHERE email = 'demo.customer@example.test';

-- 4) Check audit log. Trigger should have logged order insert.
SELECT audit_id, order_id, action_type, changed_at, changed_by
FROM capstone.order_audit
ORDER BY audit_id DESC
LIMIT 10;

-- 5) Check materialized view. It is a snapshot and needs refresh to include newer data.
REFRESH MATERIALIZED VIEW CONCURRENTLY capstone.monthly_order_metrics;
SELECT * FROM capstone.monthly_order_metrics
ORDER BY order_month DESC, order_status;

-- 6) Check an order query plan.
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_status, total_amount, created_at
FROM capstone.orders
WHERE customer_id = (
    SELECT customer_id FROM capstone.customers
    WHERE email = 'demo.customer@example.test'
)
ORDER BY created_at DESC;
