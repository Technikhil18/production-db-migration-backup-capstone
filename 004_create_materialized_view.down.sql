-- Migration 004 DOWN
BEGIN;
DROP MATERIALIZED VIEW IF EXISTS capstone.monthly_order_metrics;
COMMIT;
