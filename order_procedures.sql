-- Stored procedure: create an order and return its generated order_id.
-- The audit trigger from migration 002 logs the INSERT in the same transaction.
CREATE OR REPLACE PROCEDURE capstone.create_order(
    IN p_customer_id BIGINT,
    IN p_total_amount NUMERIC(12,2),
    OUT p_order_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_total_amount IS NULL OR p_total_amount < 0 THEN
        RAISE EXCEPTION 'Order amount must be zero or greater';
    END IF;

    INSERT INTO capstone.orders (customer_id, total_amount)
    VALUES (p_customer_id, p_total_amount)
    RETURNING order_id INTO p_order_id;
END;
$$;

-- Example usage (the OUT argument is written as NULL in CALL):
-- CALL capstone.create_order(1, 1499.00, NULL);
--
-- Refresh analytics after data changes. CONCURRENTLY requires a qualifying
-- unique index and the materialized view must already be populated.
-- REFRESH MATERIALIZED VIEW CONCURRENTLY capstone.monthly_order_metrics;
