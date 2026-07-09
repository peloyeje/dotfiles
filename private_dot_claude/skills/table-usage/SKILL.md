---
name: table-usage
description: "Analyze usage patterns of one or more Glue/datalake tables using the observability layer. Use this skill whenever the user asks about table usage, who uses a table, how often a table is queried, whether a table is still used, query trends, top consumers, or wants to qualify usage as automated vs human. Triggers on phrases like 'who uses', 'is X used', 'usage of', 'how many queries', 'check usage', 'table consumers', 'any reads/writes on', or 'can I drop this table'."
---

# Table Usage Analysis

Analyze usage for one or more datalake tables: volume, trend, consumers, query nature (automated vs human).

Default profile: `lbc-data-prod-admin`. Use `lbc-data-dev-admin` only if user asks for QA.
If no dot in table name, assume `datalake` database. Default window: last 7 days vs prior 7 days.

## Single bash call

Substitute `MY_DB` and `MY_TABLE`, run the entire block in **one Bash tool call**. All 4 queries fire in parallel; output is captured to files to avoid interleaving.

```bash
PROF=lbc-data-prod-admin
aq() { uvx --extra-index-url https://pypi.org/simple/ athenacli \
  --work_group observability --profile $PROF \
  --region eu-west-1 --table-format github -e "$1" > "$2" 2>&1; }

cat > /tmp/q_vol.sql << 'SQL'
WITH cur AS (
  SELECT SUM(read_query_count) reads, SUM(write_query_count) writes,
         SUM(query_count) total, MAX(distinct_users) peak_users
  FROM observability.table_usage_daily
  WHERE database_name='MY_DB' AND table_name='MY_TABLE'
    AND business_date >= current_date - INTERVAL '7' DAY
), prev AS (
  SELECT SUM(read_query_count) reads, SUM(write_query_count) writes,
         SUM(query_count) total
  FROM observability.table_usage_daily
  WHERE database_name='MY_DB' AND table_name='MY_TABLE'
    AND business_date >= current_date - INTERVAL '14' DAY
    AND business_date  < current_date - INTERVAL '7' DAY
)
SELECT c.reads, c.writes, c.total, p.reads prev_reads, p.writes prev_writes,
       p.total prev_total,
       ROUND(100.0*(c.total-p.total)/NULLIF(p.total,0),1) pct_change, c.peak_users
FROM cur c, prev p;
SQL

cat > /tmp/q_who.sql << 'SQL'
SELECT identity_name, identity_type, query_engine,
       SUM(read_query_count) reads, SUM(write_query_count) writes,
       SUM(query_count) total
FROM observability.table_usage_per_user_daily
WHERE database_name='MY_DB' AND table_name='MY_TABLE'
  AND business_date >= current_date - INTERVAL '7' DAY
GROUP BY 1,2,3 ORDER BY total DESC LIMIT 20;
SQL

cat > /tmp/q_ath.sql << 'SQL'
SELECT q.identity_name, q.identity_type, q.type, q.started_at,
       q.duration_seconds, ROUND(q.data_scanned_gb,4) gb, q.sql
FROM observability.athena_dml_queries q
CROSS JOIN UNNEST(q.source_table_ids) AS t(tid)
WHERE t.tid IN (SELECT DISTINCT table_id FROM observability.table_usage_daily
                WHERE database_name='MY_DB' AND table_name='MY_TABLE')
  AND q.business_date >= current_date - INTERVAL '7' DAY
ORDER BY q.started_at DESC LIMIT 10;
SQL

cat > /tmp/q_rs.sql << 'SQL'
SELECT q.identity_name, q.identity_type, q.type, q.started_at,
       q.duration_seconds, q.sql
FROM observability.redshift_dml_queries q
CROSS JOIN UNNEST(q.source_table_ids) AS t(tid)
WHERE t.tid IN (SELECT DISTINCT table_id FROM observability.table_usage_daily
                WHERE database_name='MY_DB' AND table_name='MY_TABLE')
  AND q.business_date >= current_date - INTERVAL '7' DAY
ORDER BY q.started_at DESC LIMIT 10;
SQL

aq /tmp/q_vol.sql /tmp/r_vol.txt & aq /tmp/q_who.sql /tmp/r_who.txt &
aq /tmp/q_ath.sql /tmp/r_ath.txt & aq /tmp/q_rs.sql  /tmp/r_rs.txt  &
wait

echo "=== Volume + trend ===" && cat /tmp/r_vol.txt
echo "=== Top consumers ===" && cat /tmp/r_who.txt
echo "=== Athena samples ===" && cat /tmp/r_ath.txt
echo "=== Redshift samples ===" && cat /tmp/r_rs.txt
```

For write activity, swap `source_table_ids` → `sink_table_ids` in q_ath and q_rs.
For multiple tables, repeat the block per table.

## Automation classification

| Signal | Label |
|--------|-------|
| `identity_type = role/service_account`, name ends `-sa/-svc/-bot` | Automated |
| `airflow` in identity | Pipeline (Airflow) |
| SQL contains `/* tableau */`, QuickSight, DataGrip markers | Tool extract |
| Human `firstname.lastname` + ad-hoc SQL | Human |

## Report format

**`MY_DB.MY_TABLE` - last 7d vs prior 7d**
- Volume table: reads/writes/total, this vs prev, % change
- Top consumers: identity, type, engine, reads, writes, classification
- 2-3 representative SQL snippets
- One-paragraph summary: activity level, dominant pattern, trend, recommendation

Multiple tables: one section per table + combined summary at end.

## Edge cases

- No rows in `table_usage_daily`: never queried - strong cleanup signal.
- Only `write_query_count > 0`: written but never read.
- DML queries return nothing: data outside retention window; note this.
