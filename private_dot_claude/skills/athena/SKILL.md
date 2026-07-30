---
name: athena
description: "Run read-only SQL queries on AWS Athena via athenacli. Use this skill whenever the user says 'query Athena', 'run on Athena', 'check Athena', 'look up in Athena', or asks to retrieve data from Athena tables. Also triggers on requests to explore Athena databases, list tables, or inspect table schemas."
---

# Athena SQL

Run SQL queries against AWS Athena via athenacli. Read-only: destructive statements (DROP, DELETE, INSERT, UPDATE, MERGE, CREATE, ALTER, TRUNCATE) are forbidden.

## Arguments

The slash command receives a SQL query (or a natural-language description to convert to SQL) as its argument.

## Environment selection

Ask the user which environment to target if not obvious from context:

| Environment | AWS_PROFILE |
|-------------|-------------|
| qa (dev) | `lbc-data-dev-admin` |
| prod | `lbc-data-prod-admin` |

Default to **qa** when ambiguous.

## Execution

1. Write the query to a temp file to avoid shell quoting issues:

```bash
cat > /tmp/athena_query.sql << 'QUERY'
<sql>
QUERY
```

2. Run athenacli with the file:

```bash
uvx --extra-index-url https://pypi.org/simple/ athenacli \
  --work_group observability \
  --profile <aws_profile> \
  --region eu-west-1 \
  -e /tmp/athena_query.sql
```

## Output format

Default output is CSV-like (comma-separated with header row). Use `--table-format` to change:

| Format | Flag | Use case |
|--------|------|----------|
| CSV | `--table-format csv` | Default, good for piping |
| Markdown | `--table-format github` | Readable in conversation |
| ASCII table | `--table-format ascii` | Aligned columns |
| TSV | `--table-format tsv` | Tab-separated |

Use `github` format when displaying results inline. Use `csv` when the user wants to export or process data further.

## Useful commands

- `SHOW DATABASES;` - list all databases
- `SHOW TABLES IN <database>;` - list tables
- `SHOW COLUMNS IN <database>.<table>;` - list columns
- `SHOW CREATE TABLE <database>.<table>;` - full DDL with comments

Specify the database as a positional argument to avoid qualifying every table:

```bash
uvx --extra-index-url https://pypi.org/simple/ athenacli \
  --work_group observability \
  --profile <aws_profile> \
  --region eu-west-1 \
  <database> \
  -e /tmp/athena_query.sql
```

## Safety

NEVER execute destructive queries. If the user's request would require DROP, DELETE, INSERT, UPDATE, MERGE, CREATE, ALTER, or TRUNCATE, refuse and explain why.

Multiple statements separated by `;` in a single file are supported and execute sequentially.
