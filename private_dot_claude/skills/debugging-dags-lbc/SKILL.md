---
name: debugging-dags-lbc
description: Leboncoin context for diagnosing Airflow DAG failures in the data-engineering monorepo — DAG naming convention and dev/qa/prod environments. Pair with debugging-dags whenever that skill would trigger here: invoke debugging-dags for the investigation itself, this skill to decode dag_ids and pick the right `af` instance.
---

# Debugging DAGs at leboncoin

Invoke **debugging-dags** for the investigation itself (identify failure, pull logs, categorize, report
root cause). This skill only supplies the two pieces of context that skill can't know on its own: how
dag_ids are built, and which Airflow environment to point `af` at.

## Airflow environments

Three: **dev**, **qa**, **prod** (`LBC_ENV` env var; see `apps/lbc_pipelines/src/modules/lbc/airflow/env.py`),
each with a matching `af` instance. Pick by context — prod incident/alerting link means prod, "does my fix
work" after a local change means dev/qa — then switch directly:

```bash
af instance use <env>
```

It's idempotent (local config rewrite, no network call) — skip the `af instance current` check and switch
unconditionally. Diagnosing against the wrong environment silently wastes a full investigation, since dag
runs/ids can exist (or fail differently) in more than one.

## DAG naming convention

DAG ids follow a fixed grammar (`apps/lbc_pipelines/src/modules/lbc/airflow/helpers/naming.py`, enums in
`.../airflow/constants/pipelines.py`):

```
<domain>_<scope>[_<details>][_<schema>][_<schedule>][_backfill][__dbx]
```

- **domain** — business domain, one of `DOMAINS` (e.g. `bi`, `crm`, `databricks`)
- **scope** — functional area within the domain, one of `SCOPES` (e.g. `user`, `redshift`, `salesforce`)
- **details** — free-form disambiguating words, optional
- **schema** — warehouse layer, one of `SCHEMAS` (e.g. `l0`, `l1`, `l2`, `cl`, `raw`), optional
- **schedule** — run cadence, one of `SCHEDULES` (e.g. `hourly`, `daily`, `weekly`, `monthly`)
- **backfill**/**__dbx** — literal suffixes marking a backfill-mode variant or a Databricks port of the same DAG

Decode a dag_id by eye instead of opening its source — e.g. `bi_user_pro_kpis_l2_weekly` is domain `bi`,
scope `user`, details `pro_kpis`, schema `l2`, schedule `weekly` — and use it to predict a *related* DAG's
id (daily variant, backfill counterpart, `__dbx` port) when tracing sensors or lineage. If it doesn't
parse, the DAG predates the convention; `DagAttributes.from_dag_id(dag_id)` in that module gives the
authoritative parse (or raises `DagIdParseError`) without guessing.

## Related skills

- **airflow** — general `af` CLI reference.
