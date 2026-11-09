# Hands-On Lab: Audit Logging, Category Trees, and Safe Migrations

PostgreSQL lab covering trigger-based audit logging, a hierarchical category
tree (recursive CTE), versioned migrations with Flyway, and least-privilege roles.

## Repo layout

```
migrations/
  V1__core_tables.sql    students table + seed rows
  V2__audit_log.sql      audit_log table, audit() function, trg_audit trigger
  V3__categories.sql     categories table + sample tree
sql/
  step2_watch_audit_log.sql
  step3_category_tree.sql
  step5_security.sql
flyway.conf
```

## Prerequisites

- PostgreSQL running locally with a database named `bootcamp`
- `psql` and [Flyway CLI](https://documentation.red-gate.com/flyway) installed

```bash
createdb -U postgres bootcamp
```

## Step 1 - Audit log
Implemented in `migrations/V2__audit_log.sql`. It creates `audit_log`, the
`audit()` trigger function, and `trg_audit` on `students` (fires AFTER
INSERT/UPDATE/DELETE per row and stores old/new rows as JSONB).

## Step 2 - Watch the audit log work
```bash
psql -U postgres -d bootcamp -f sql/step2_watch_audit_log.sql
```
Expected: an `UPDATE` row (Kofi -> Kofi M.) and a `DELETE` row (Juma -> empty).

## Step 3 - Category tree
Table is created in `migrations/V3__categories.sql`.
```bash
psql -U postgres -d bootcamp -f sql/step3_category_tree.sql
```
Expected output:
```
Electronics
  Computers
  Phones
    Laptops
```

## Step 4 - Versioned migrations with Flyway
Run from the repo root (so `flyway.conf` is picked up):
```bash
flyway -password=YOUR_PASSWORD migrate
flyway -password=YOUR_PASSWORD info
```
`info` should list V1, V2 and V3 as `Success`. Flyway also creates a
`flyway_schema_history` table that records every applied version.

Run Step 4 **before** Steps 2 and 3 on a fresh database, since the
migrations create the tables those steps use.

## Step 5 - Least-privilege security
Run as a superuser after the migrations:
```bash
psql -U postgres -d bootcamp -f sql/step5_security.sql
```
Verify:
```bash
psql -U api -d bootcamp -c "SELECT count(*) FROM students;"      # works
psql -U api -d bootcamp -c "CREATE TABLE x(i int);"              # permission denied
psql -U api -d bootcamp -c "UPDATE audit_log SET op='X';"        # permission denied
```

Two small additions beyond the lab text: `GRANT USAGE ON ALL SEQUENCES` (needed
to INSERT into `categories`, which uses SERIAL) and
`REVOKE UPDATE, DELETE ON audit_log FROM app_write` (so the app cannot rewrite
its own audit trail). Change the `strong-secret` password outside of a lab.

## Wrap-up
Change tracking, hierarchical data modeling, controlled schema evolution,
and least-privilege access control.
