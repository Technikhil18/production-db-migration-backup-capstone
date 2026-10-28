-- Migration 001 UP: core application schema
BEGIN;

CREATE SCHEMA IF NOT EXISTS capstone;

CREATE TABLE capstone.customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE capstone.orders (
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES capstone.customers(customer_id),
    order_status TEXT NOT NULL DEFAULT 'pending'
        CHECK (order_status IN ('pending', 'paid', 'shipped', 'cancelled')),
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_customer_created
    ON capstone.orders (customer_id, created_at DESC);

CREATE INDEX idx_orders_status_created
    ON capstone.orders (order_status, created_at DESC);

COMMIT;
