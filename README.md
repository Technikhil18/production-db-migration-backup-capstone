# Migration Order and Rollback Notes

Apply the `.up.sql` migrations in ascending numeric order:

1. `001_create_core_tables.up.sql`
2. `002_add_audit_logging.up.sql`
3. `003_create_reporting_view.up.sql`
4. `004_create_materialized_view.up.sql`

Rollback in reverse order only when appropriate:

1. `004_create_materialized_view.down.sql`
2. `003_create_reporting_view.down.sql`
3. `002_add_audit_logging.down.sql`
4. `001_create_core_tables.down.sql`

**Warning:** the down scripts drop objects. In particular, migration 001's down script drops the entire `capstone` schema and its contents. Test rollback in a disposable database and ensure backups exist first.

These files are version-controlled migration scripts, but they do not automatically record which migrations have run. For team/production workflows, use a migration tool (for example, Flyway or Liquibase) or implement a migration-history table and apply each version exactly once.
