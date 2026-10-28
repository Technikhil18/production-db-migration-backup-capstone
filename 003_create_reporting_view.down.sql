-- Migration 003 DOWN
BEGIN;
DROP VIEW IF EXISTS capstone.customer_order_summary;
COMMIT;
