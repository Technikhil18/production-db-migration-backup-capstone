-- Migration 001 DOWN: destructive; removes core tables and schema.
BEGIN;
DROP SCHEMA IF EXISTS capstone CASCADE;
COMMIT;
