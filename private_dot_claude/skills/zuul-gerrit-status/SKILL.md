---
name: zuul-gerrit-status
description: Check Zuul CI job status and logs for a Gerrit change at review.leboncoin.ci. Use whenever the user asks to check CI/Zuul status for a Gerrit change or review, wants to know why a Zuul job failed on a change, pastes a review.leboncoin.ci change URL or number and asks about its checks, or asks "did CI pass" / "is the change green" / "why did the job fail" for a change in this Gerrit instance. Also use after pushing a new patchset (e.g. via git review) when checking whether it passed.
allowed-tools: Bash(~/.claude/skills/zuul-gerrit-status/scripts/zuul_status.sh:*), Bash(ssh -p 29418 review.leboncoin.ci:*), Bash(curl:*)
---

# Zuul + Gerrit status

Reports a Gerrit change's review status, every Zuul job result for its
current patchset, and (for any failing job) an excerpt of the actual error
from that job's console log — in one command instead of separately querying
Gerrit, listing Zuul builds, and fetching/decompressing a log file.

## Usage

```bash
~/.claude/skills/zuul-gerrit-status/scripts/zuul_status.sh <change_number> [job-name-substring]
```

- `change_number`: the numeric Gerrit change ID (e.g. `586061` from
  `https://review.leboncoin.ci/c/data/databricks/+/586061`).
- `job-name-substring` (optional): only show jobs whose name contains this
  string, e.g. `stale-settings` to narrow to one job family.

Example:

```bash
~/.claude/skills/zuul-gerrit-status/scripts/zuul_status.sh 586061
```

Run it once and read the output — don't re-derive the same data with
separate `ssh`/`curl` calls, that's exactly what this script replaces.

## What it does and why

1. **Gerrit change status** via `ssh -p 29418 review.leboncoin.ci gerrit
   query` — subject, open/merged status, current patchset number, and label
   approvals (e.g. `Integration+1`, `Quality-1`) including which bot/user set
   them. This is the fast way to see the verdict without opening a browser.

2. **Zuul job results** via the Zuul REST API
   (`https://zuul.leboncoin.ci/api/tenant/leboncoin/builds?change=<id>`)
   filtered to the change's *latest* patchset only — older patchsets'
   builds are excluded automatically so a fixed job from patchset 2 doesn't
   get confused with a still-failing one from patchset 4. Each row shows
   result, job name, and its log URL.

3. **Failure excerpts**: for every job whose result isn't `SUCCESS`, the
   script fetches `<log_url>job-output.txt` — Zuul serves this gzip-encoded,
   so use `curl --compressed` (or you'll get raw gzip bytes rather than
   text) — and greps for the actual `ERROR`/`fatal:`/nonzero `failed:` block
   plus a few lines of surrounding context, rather than dumping the whole
   (often several-hundred-line) log.

If the excerpt doesn't contain enough context (e.g. the real error is a
Python traceback further up, not right at the Ansible-reported failure
point), fetch the full log yourself:

```bash
curl -s --compressed "<log_url>job-output.txt"
```

## Notes

- A change can have multiple patchsets; approvals shown are always for the
  *current* one. If you need history across patchsets (e.g. "did this job
  ever pass on an earlier patchset"), query the builds API without a patchset
  filter: `curl -s "https://zuul.leboncoin.ci/api/tenant/leboncoin/builds?change=<id>" | jq`.
- `IN_PROGRESS` in the job list means the build hasn't finished yet — don't
  treat it as a failure, just re-run the script after waiting.
- This only covers Zuul + Gerrit at review.leboncoin.ci. For GitHub Actions
  use the `cicd:gha-debug` skill instead.
