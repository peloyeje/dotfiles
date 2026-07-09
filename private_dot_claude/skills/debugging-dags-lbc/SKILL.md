---
name: debugging-dags-lbc
description: DAG naming convention and dev/qa/prod context for debugging Airflow DAGs in this monorepo. Pair with debugging-dags whenever it triggers.
---

# Debugging DAGs at leboncoin

Invoke **debugging-dags** for the investigation, **airflow** for `af` CLI reference; this skill fills
what those can't know locally — dag_id structure, and which environment to target.

## Airflow environments

Three (`LBC_ENV` in `apps/lbc_pipelines/src/modules/lbc/airflow/env.py`): **dev**, **qa**, **prod**, each
with a matching `af` instance. Pick by context (prod incident -> prod, "does my fix work" -> dev/qa), then
switch directly:

```bash
af instance use <env>
```

Idempotent (local rewrite, no network call) — switch unconditionally, no need to check current first.
Wrong environment = silently wasted investigation, since dag runs/ids can exist in more than one.

## DAG naming convention

Fixed grammar (`apps/lbc_pipelines/src/modules/lbc/airflow/helpers/naming.py`, enums in
`.../airflow/constants/pipelines.py`):

```
<domain>_<scope>[_<details>][_<schema>][_<schedule>][_backfill][__dbx]
```

`domain`=business area (`bi`/`crm`/...), `scope`=sub-area (`user`/`redshift`/...), `details`=free-form
optional, `schema`=warehouse layer (`l0`/`l1`/`l2`/...) optional, `schedule`=cadence
(`daily`/`weekly`/`monthly`/...); `backfill`/`__dbx` are literal suffixes for a backfill variant or
Databricks port. Decode by eye instead of opening source, e.g. `bi_user_pro_kpis_l2_weekly` -> domain `bi`,
scope `user`, details `pro_kpis`, schema `l2`, schedule `weekly` — predicts a *related* DAG's id (daily
variant, backfill, `__dbx` port) when tracing sensors/lineage. Doesn't parse -> predates the convention;
use `DagAttributes.from_dag_id(dag_id)` instead of guessing.
