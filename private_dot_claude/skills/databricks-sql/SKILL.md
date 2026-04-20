---
name: databricks-sql
description: Execute SQL queries on a Databricks SQL warehouse via the REST API. Use this skill whenever the user wants to run SQL on Databricks, query a Delta table, test DDL statements (ALTER TABLE, COMMENT ON TABLE, CREATE TABLE), inspect catalog metadata, or verify data in Unity Catalog. Triggers on phrases like "run on Databricks", "query the table in Databricks", "execute this SQL", "test this DDL", "check Databricks", etc. Always use this skill rather than cobbling together curl commands manually.
---

# Databricks SQL

Execute SQL statements against a Databricks SQL warehouse.

## Step 1: Select a warehouse

If the user hasn't specified a warehouse, list the available ones and ask them to choose:

```bash
databricks warehouses list --output json \
  | jq -r '.[] | "\(.id)\t\(.name)\t[\(.state)]"'
```

Present the list and ask: "Which warehouse should I use? (It will start automatically if STOPPED.)"

## Step 2: Execute the statement

`wait_timeout` must be between 5s and 50s (or `0s` to disable). 50s is the practical maximum for synchronous queries:

```bash
RESULT=$(databricks api post /api/2.0/sql/statements \
  --json "{
    \"warehouse_id\": \"<warehouse_id>\",
    \"statement\": \"<sql>\",
    \"wait_timeout\": \"50s\"
  }")
echo "$RESULT" | jq .
```

Escape single quotes in the SQL with `'\''` or build the JSON payload in a temp file to avoid shell quoting issues with complex queries.

## Step 3: Handle the response

Check `status.state`:

**SUCCEEDED** — extract and display results:

```bash
# Column headers
echo "$RESULT" | jq -r '.manifest.schema.columns[].name' | tr '\n' '\t' | sed 's/\t$/\n/'

# Rows (empty result set if data_array is null)
echo "$RESULT" | jq -r '(.result.data_array // [])[] | @tsv'
```

Pipe through `column -t -s $'\t'` for aligned output when the result set is small (< 1000 rows).

**FAILED**:

```bash
echo "$RESULT" | jq -r '.status.error | "\(.error_code): \(.message)"'
```

**PENDING or RUNNING** — poll until done (warehouse may be starting up):

```bash
STMT_ID=$(echo "$RESULT" | jq -r '.statement_id')
while true; do
  RESULT=$(databricks api get "/api/2.0/sql/statements/$STMT_ID")
  STATE=$(echo "$RESULT" | jq -r '.status.state')
  echo "State: $STATE" >&2
  [[ "$STATE" == "SUCCEEDED" || "$STATE" == "FAILED" || "$STATE" == "CANCELED" ]] && break
  sleep 5
done
```

Then display results as in the SUCCEEDED branch above.

## Tips

- **DDL statements** (ALTER, CREATE, COMMENT ON TABLE) return 0 rows — SUCCEEDED with empty `data_array` is the success signal.
- **Backtick-quote identifiers** (`` `catalog`.`schema`.`table` ``, `` `col_name` ``) whenever a name could be a reserved keyword, contain dots, or have special characters. Plain alphanumeric names work unquoted, but backticks are always safe.
- **Multi-statement batches**: send them in a single `statement` string separated by `;` — the API executes them sequentially.

## Schema inspection without a warehouse

If no warehouse is available (or the user only wants UC-stored metadata, not a live DESCRIBE), use the Unity Catalog REST API directly — no warehouse needed:

```bash
databricks api get /api/2.1/unity-catalog/tables/<catalog>.<schema>.<table> \
  | jq '{columns: [.columns[] | {name, type_text, comment}]}'
```

This returns the metadata as registered in the catalog. `DESCRIBE TABLE` via SQL is preferable when you also want partition info, table statistics, or live schema state.
