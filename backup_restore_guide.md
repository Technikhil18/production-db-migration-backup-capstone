# Database Backup & Disaster Recovery Guide

This guide uses PostgreSQL logical backups. Adapt retention, encryption, access control, and recovery targets to your own environment.

## 1. Define recovery objectives first
- **RPO (Recovery Point Objective):** maximum acceptable data loss measured in time.
- **RTO (Recovery Time Objective):** maximum acceptable time to restore service.
- Example values are organization-specific; do not assume a single schedule is right for every database.

## 2. Create a compressed logical backup

Run from a shell, not from the SQL prompt:

```bash
pg_dump -U postgres -d capstone_db -Fc -f capstone_db_$(date +%Y%m%d_%H%M%S).dump
```

On Windows PowerShell, use a filename such as `capstone_db_20261028.dump` instead of the `$(date ...)` expression.

`-Fc` creates a custom-format archive suitable for selective restore with `pg_restore`.

## 3. Back up roles/global objects when needed

```bash
pg_dumpall -U postgres --globals-only > postgres_globals.sql
```

Protect this file because it can contain role definitions and security-related metadata. Do not commit real backups, passwords, or secrets to GitHub.

## 4. Verify the backup file

```bash
pg_restore --list capstone_db_20261028.dump
```

A readable archive listing is a useful check, but it is not a substitute for a test restore.

## 5. Restore into a separate test database

Create an empty test database first:

```bash
createdb -U postgres capstone_restore_test
pg_restore -U postgres -d capstone_restore_test --no-owner --no-privileges capstone_db_20261028.dump
```

Then verify important tables, row counts, constraints, views, procedures, and application queries. Do not overwrite the source database during practice.

## 6. Recovery checklist
1. Declare the incident and identify the target recovery point.
2. Provision a clean PostgreSQL instance or recovery environment.
3. Restore roles/globals as appropriate and securely.
4. Restore the selected backup.
5. If point-in-time recovery is required, restore a base backup and replay archived WAL to the target time; logical `pg_dump` alone does not provide PITR.
6. Validate row counts, constraints, extensions, permissions, and application health.
7. Redirect application traffic only after validation.
8. Document actual recovery time and any data loss versus RTO/RPO targets.

## 7. Production safeguards
- Encrypt backups in transit and at rest.
- Store copies off-site and consider immutable retention.
- Use a dedicated least-privilege backup identity.
- Monitor backup success, age, storage capacity, and restore tests.
- Keep backup retention aligned with policy and legal requirements.
- Test restores regularly; an untested backup is not proven recoverable.
- Keep credentials and backup archives out of source control.
