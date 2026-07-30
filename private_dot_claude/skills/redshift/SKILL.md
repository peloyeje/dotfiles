---
name: redshift
description: "Run read-only SQL queries on AWS Redshift via psql with temporary IAM credentials. Use this skill whenever the user says 'query Redshift', 'run on Redshift', 'check Redshift', 'look up in Redshift', or asks to retrieve data from Redshift tables, inspect schemas, or explore the data warehouse. Also triggers on mentions of dwhprod, dwhqa3, or the lbc-dwh-db cluster."
---

# Redshift SQL

Run SQL queries against AWS Redshift using psql with short-lived IAM credentials. Read-only: destructive statements (DROP, DELETE, INSERT, UPDATE, CREATE, ALTER, TRUNCATE, COPY, UNLOAD) are forbidden.

## Arguments

The slash command receives a SQL query (or a natural-language description to convert to SQL) as its argument.

## Environment selection

Ask the user which environment to target if not obvious from context. Default to **qa** when ambiguous.

| Environment | Profile | Cluster | Database | Endpoint |
|-------------|---------|---------|----------|----------|
| qa (dev) | `lbc-data-dev-admin` | `lbc-dwh-db-qa` | `dwhqa3` | `lbc-dwh-db-qa.cr0h6xo83jaf.eu-west-1.redshift.amazonaws.com` |
| prod | `lbc-data-prod-admin` | `lbc-dwh-db-prod` | `dwhprod` | `lbc-dwh-db-prod.ciyt8atsu4jq.eu-west-1.redshift.amazonaws.com` |

Port is always `5439`.

## Execution

1. Write the query to a temp file to avoid shell quoting issues:

```bash
cat > /tmp/redshift_query.sql << 'SQL'
<query>
SQL
```

2. Get temporary credentials and run the query:

```bash
CREDS=$(aws redshift get-cluster-credentials \
  --cluster-identifier <cluster> \
  --db-user dba \
  --db-name <database> \
  --profile <profile> \
  --region eu-west-1 \
  --output json) && \
DB_USER=$(echo "$CREDS" | python3 -c "import sys,json; print(json.load(sys.stdin)['DbUser'])") && \
DB_PASS=$(echo "$CREDS" | python3 -c "import sys,json; print(json.load(sys.stdin)['DbPassword'])") && \
PGPASSWORD="$DB_PASS" psql \
  -h <endpoint> \
  -p 5439 -U "$DB_USER" -d <database> \
  -f /tmp/redshift_query.sql
```

## Output format

psql supports several output modes via flags:

| Format | Flag | Use case |
|--------|------|----------|
| Aligned (default) | (none) | Readable tables with borders |
| CSV | `--csv` | Export, piping to other tools |
| Tuples only | `-t` | Raw data without headers/footers |
| HTML | `-H` | Structured output |
| Expanded | `-x` | Wide rows displayed vertically |

Use the default aligned format when displaying results inline. Use `--csv` when the user wants to export data.

## Useful commands

- `SELECT datname FROM pg_database;` - list databases
- `SELECT schemaname, tablename FROM pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema') ORDER BY 1, 2;` - list user tables
- `SELECT * FROM pg_table_def WHERE schemaname = '<schema>' AND tablename = '<table>';` - describe table columns
- `SELECT * FROM svv_table_info WHERE schema = '<schema>' AND "table" = '<table>';` - table stats (rows, size)
- `\dn` - list schemas (use `-c '\dn'` flag instead of `-f`)

For psql meta-commands (`\d`, `\dn`, `\dt`), pass them via `-c` instead of writing to a file:

```bash
PGPASSWORD="$DB_PASS" psql -h <endpoint> -p 5439 -U "$DB_USER" -d <database> -c '\dt <schema>.*'
```

## Safety

Never execute destructive queries. If the user's request would require DROP, DELETE, INSERT, UPDATE, CREATE, ALTER, TRUNCATE, COPY, or UNLOAD, refuse and explain why.

Credentials expire after 15 minutes (900s default). If a session times out, re-run the `get-cluster-credentials` step.

If the connection times out (hangs or network unreachable), ask the user if VPNLBC is enabled - the Redshift clusters are only reachable through VPN.
