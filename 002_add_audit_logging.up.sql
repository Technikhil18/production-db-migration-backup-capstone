-- Migration 002 UP: audit table and trigger
BEGIN;

CREATE TABLE capstone.order_audit (
    audit_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL,
    action_type TEXT NOT NULL CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE')),
    old_row JSONB,
    new_row JSONB,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by TEXT NOT NULL DEFAULT CURRENT_USER
);

CREATE INDEX idx_order_audit_order_changed
    ON capstone.order_audit (order_id, changed_at DESC);

CREATE OR REPLACE FUNCTION capstone.log_order_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO capstone.order_audit (order_id, action_type, new_row)
        VALUES (NEW.order_id, TG_OP, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO capstone.order_audit (order_id, action_type, old_row, new_row)
        VALUES (NEW.order_id, TG_OP, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSE
        INSERT INTO capstone.order_audit (order_id, action_type, old_row)
        VALUES (OLD.order_id, TG_OP, to_jsonb(OLD));
        RETURN OLD;
    END IF;
END;
$$;

CREATE TRIGGER trg_orders_audit
AFTER INSERT OR UPDATE OR DELETE ON capstone.orders
FOR EACH ROW EXECUTE FUNCTION capstone.log_order_change();

COMMIT;
