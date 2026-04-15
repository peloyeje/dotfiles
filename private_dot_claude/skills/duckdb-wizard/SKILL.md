---
name: duckdb-wizard
description: Launch DuckDB with AWS authentication pre-configured for querying S3 data. Use this skill whenever the user wants to run DuckDB against S3, query parquet/csv files on S3, or needs a DuckDB session with AWS credentials. Also use when the user asks how to set up DuckDB with AWS, fix S3 authentication errors in DuckDB, or read data from s3:// URIs.
allowed-tools: Bash(uv tool run --from duckdb*), Bash(aws s3 ls:*), Bash(aws sso login:*)
---

# DuckDB with AWS Authentication

Launch a local DuckDB session pre-configured for authenticated S3 access.

## Modes

### Interactive shell (default)

```bash
AWS_PROFILE=<profile> AWS_REGION=<region> uv tool run --from duckdb==1.5 duckdb \
  -cmd "SET s3_url_style = 'path'; CREATE OR REPLACE SECRET secret (TYPE s3, PROVIDER credential_chain, REGION '<region>');"
```

### UI mode (`-ui`)

Launches the DuckDB local web UI instead of the CLI shell:

```bash
AWS_PROFILE=<profile> AWS_REGION=<region> uv tool run --from duckdb==1.5 duckdb \
  -cmd "SET s3_url_style = 'path'; CREATE OR REPLACE SECRET secret (TYPE s3, PROVIDER credential_chain, REGION '<region>');" \
  -ui
```

### Ad-hoc query (`-c`)

Run a single query without entering the shell:

```bash
AWS_PROFILE=<profile> AWS_REGION=<region> uv tool run --from duckdb==1.5 duckdb \
  -cmd "SET s3_url_style = 'path'; CREATE OR REPLACE SECRET secret (TYPE s3, PROVIDER credential_chain, REGION '<region>');" \
  -c "SELECT * FROM read_parquet('s3://bucket/path/*') LIMIT 10;"
```

## Notes

- `s3_url_style = 'path'` - required for buckets with dots in the name (e.g. `data.prod.example.com`), which break virtual-hosted-style SSL certificates
- `credential_chain` - picks up credentials in order: env vars, AWS profile, instance metadata

## Substituting user values

Ask the user for:
- **AWS profile** - the `AWS_PROFILE` value (e.g. `lbc-data-prod-admin`)
- **Region** - used both as env var and inside the secret (e.g. `eu-west-1`)

If they've already specified these in conversation, use those values directly.

## Common errors

| Error | Cause | Fix |
|-------|-------|-----|
| `SSL peer certificate... not OK` | Bucket name has dots, virtual-hosted URL breaks SSL | Already fixed by `s3_url_style = 'path'` |
| `HTTP 403 Forbidden` / `No credentials` | DuckDB not picking up AWS creds | Add the `CREATE SECRET ... credential_chain` line |
| `HTTP 403` after secret created | Wrong profile or profile lacks permissions | Verify with `aws s3 ls s3://bucket --profile <profile>` |
