---
name: consul-kv
description: Use when needing to read or explore Consul KV store keys, check infrastructure metadata, or verify Consul prerequisites for Terraform changes
---

# Consul KV

Read and explore the Consul KV store.

## Setup

```bash
CONSUL_ADDR="https://consul.leboncoin.ci:8500"
```

Read access does not require a token.

## Read operations

### List keys under a prefix

```bash
curl -s "$CONSUL_ADDR/v1/kv/<prefix>/?keys"
```

Returns a JSON array of full key paths.

### Get a raw value

```bash
curl -s "$CONSUL_ADDR/v1/kv/<full-key-path>?raw"
```

Returns the raw value as plain text.

### List subkeys (one level)

Append `separator=/` to list only immediate children:

```bash
curl -s "$CONSUL_ADDR/v1/kv/<prefix>/?keys&separator=/"
```

## Write operations

Write operations require a Consul token from Vault:

```bash
CONSUL_TOKEN=$(vault read -field token services/prd/consul/tokens/terraform/lbc-data)
curl -s -X PUT -H "X-Consul-Token: $CONSUL_TOKEN" \
  "$CONSUL_ADDR/v1/kv/<key>" -d '<value>'
```

## Tips

- Always use `?raw` when fetching values to get plain text instead of base64-encoded JSON
- Use `?keys` to discover structure before fetching values
- Use `?keys&separator=/` to browse one level at a time (like `ls` vs `find`)
- Pipe to `jq .` for readable key listings
