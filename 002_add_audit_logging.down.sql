-- Migration 002 DOWN: removes the audit trigger and audit table.
BEGIN;
DROP TRIGGER IF EXISTS trg_orders_audit ON capstone.orders;
DROP FUNCTION IF EXISTS capstone.log_order_change();
DROP TABLE IF EXISTS capstone.order_audit;
COMMIT;
