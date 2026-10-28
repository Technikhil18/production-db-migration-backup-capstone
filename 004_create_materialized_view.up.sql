-- Migration 004 UP: materialized monthly analytics view
BEGIN;

CREATE MATERIALIZED VIEW capstone.monthly_order_metrics AS
SELECT
    DATE_TRUNC('month', created_at)::DATE AS order_month,
    order_status,
    COUNT(*) AS order_count,
    SUM(total_amount)::NUMERIC(16,2) AS total_amount
FROM capstone.orders
GROUP BY DATE_TRUNC('month', created_at)::DATE, order_status
WITH DATA;

-- Unique index permits REFRESH MATERIALIZED VIEW CONCURRENTLY after initial creation.
CREATE UNIQUE INDEX uq_monthly_order_metrics_month_status
    ON capstone.monthly_order_metrics (order_month, order_status);

COMMIT;
