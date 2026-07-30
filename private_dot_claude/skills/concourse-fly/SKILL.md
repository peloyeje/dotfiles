---
name: concourse-fly
description: Use this skill to interact with Concourse CI at delivery.leboncoin.ci using the fly CLI. Invoke whenever the user wants to trigger a prod job, check pipeline status, watch build logs, pause/unpause a pipeline or job, list builds, or do anything with Concourse pipelines or jobs. Trigger on phrases like "trigger the job", "run the pipeline", "check the build", "watch the logs", "pause the pipeline", or any mention of Concourse, fly CLI, or CI pipeline management.
allowed-tools: Bash(fly:*)
---

# Concourse fly CLI skill

## Setup

**Target:** `lbc` (pre-configured, points to https://delivery.leboncoin.ci)

**Authentication:** The `lbc` target is already saved. If a command returns "not authorized", re-authenticate:
```bash
fly -t lbc login -b  # opens browser for SSO
```

Always prefix commands with `-t lbc`.

## Teams

Concourse organizes pipelines under teams. The `lbc` target has a default team, but pipelines may belong to a different team.

**Always ask the user which team the pipeline belongs to** before running any pipeline or job operation, unless they already specified it. Then pass `--team <team-name>` to every command.

To list known teams:
```bash
fly -t lbc teams
```

## Common tasks

### Trigger a job

```bash
fly -t lbc trigger-job -j <pipeline>/<job> --team <team>
# With live log streaming:
fly -t lbc trigger-job -j <pipeline>/<job> --team <team> -w
```

The job name is the name defined in the pipeline config. If unsure, list jobs first (see below).

### List jobs in a pipeline

```bash
fly -t lbc jobs -p <pipeline> --team <team>
```

This shows all jobs with their status (started/succeeded/failed/paused).

### Watch a running build

```bash
# Watch latest build for a job:
fly -t lbc watch -j <pipeline>/<job> --team <team>
# Watch a specific build number:
fly -t lbc watch -b <build-number>
```

### Check recent builds

```bash
# Last builds for a specific job:
fly -t lbc builds -j <pipeline>/<job> --team <team>
# Last builds across a pipeline:
fly -t lbc builds -p <pipeline> --team <team>
# Show more results:
fly -t lbc builds -j <pipeline>/<job> --team <team> -c 20
```

### List all pipelines

```bash
fly -t lbc pipelines
# Include archived:
fly -t lbc pipelines --include-archived
```

### Pause / unpause a pipeline

```bash
fly -t lbc pause-pipeline -p <pipeline> --team <team>
fly -t lbc unpause-pipeline -p <pipeline> --team <team>
```

### Pause / unpause a job

```bash
fly -t lbc pause-job -j <pipeline>/<job> --team <team>
fly -t lbc unpause-job -j <pipeline>/<job> --team <team>
```

### Abort a running build

```bash
fly -t lbc abort-build -j <pipeline>/<job> -b <build-number>
```

### Rerun a build

```bash
fly -t lbc rerun-build -j <pipeline>/<job> -b <build-number>
```

## Workflow for triggering jobs

### Single pipeline
1. Ask the user for the team name if not provided.
2. Run `fly -t lbc jobs -p <pipeline> --team <team>` to list available jobs and their current status.
3. Identify the right job (ask the user if ambiguous).
4. Trigger with `-w` to stream logs: `fly -t lbc trigger-job -j <pipeline>/<job> --team <team> -w`
5. Report outcome (succeeded/failed) and any relevant log lines on failure.

### Multiple pipelines (bulk trigger)
When the user provides a list of pipelines and specifies which jobs to trigger (e.g., "trigger staging and prod for all these pipelines"):

1. Ask for the team name if not provided.
2. If job names are unknown, list jobs for all pipelines **in parallel** first.
3. Once job names are confirmed, trigger all jobs **in parallel** in a single message — don't wait for one to finish before starting the next.
4. Present results as a summary table (pipeline | job | build number).

Avoid `-w` when triggering many jobs at once — streaming logs serially defeats the purpose of parallel triggering. Let the user watch individual builds separately if needed.

## Error handling

| Error | Fix |
|---|---|
| `not authorized` | Ask the user which team to authenticate against, then tell them to run `! fly -t lbc login -b -n <team>` in the prompt (the `!` prefix runs it in-session so the auth lands in the conversation). You cannot run browser-based login yourself. |
| `unknown target` | Tell the user to run `! fly -t lbc login -c https://delivery.leboncoin.ci -b -n <team>` |
| `job not found` | Run `fly -t lbc jobs -p <pipeline> --team <team>` to see exact job names |
| pipeline paused | Run `fly -t lbc unpause-pipeline -p <pipeline> --team <team>` first |
