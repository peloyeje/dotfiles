#!/usr/bin/env bash
# Report Zuul CI job status for a Gerrit change in one shot: change/patchset
# info, per-job pass/fail for the latest patchset, and (for any failed job) a
# trimmed excerpt of the failure from its console log. Avoids the separate
# ssh + curl + gunzip + grep steps this otherwise takes.
set -euo pipefail

CHANGE="${1:?usage: zuul_status.sh <change_number> [job-name-substring]}"
JOB_FILTER="${2:-}"

GERRIT_HOST="review.leboncoin.ci"
GERRIT_PORT=29418
ZUUL_API="https://zuul.leboncoin.ci/api/tenant/leboncoin"

echo "== Gerrit change ${CHANGE} =="
CHANGE_JSON=$(ssh -p "$GERRIT_PORT" "$GERRIT_HOST" gerrit query --format=JSON "change:${CHANGE}" --current-patch-set 2>/dev/null | head -1)
echo "$CHANGE_JSON" | jq -r '
  "\(.subject)\nstatus: \(.status)\ncurrentPatchSet: \(.currentPatchSet.number)\n" +
  "approvals: " + ([.currentPatchSet.approvals[]? | "\(.type)=\(.value)(\(.by.username))"] | join(", "))
'

echo
echo "== Zuul builds (latest patchset) =="
BUILDS_JSON=$(curl -s "${ZUUL_API}/builds?change=${CHANGE}&limit=50")
LATEST_PS=$(echo "$BUILDS_JSON" | jq '[.[].ref.patchset | tonumber] | max')

echo "$BUILDS_JSON" | jq -r --argjson ps "$LATEST_PS" --arg filter "$JOB_FILTER" '
  [.[] | select((.ref.patchset|tonumber) == $ps) | select(.job_name | contains($filter))]
  | sort_by(.job_name)
  | .[] | "\(.result // "IN_PROGRESS")\t\(.job_name)\t\(.log_url // "")"
' | column -t -s $'\t'

FAILED_LOGS=$(echo "$BUILDS_JSON" | jq -r --argjson ps "$LATEST_PS" '
  [.[] | select((.ref.patchset|tonumber) == $ps) | select(.result != "SUCCESS" and .result != null)]
  | .[].log_url // empty
')

if [ -n "$FAILED_LOGS" ]; then
  echo
  echo "== Failure excerpts =="
  while IFS= read -r log_url; do
    [ -z "$log_url" ] && continue
    echo "--- ${log_url} ---"
    curl -s --compressed "${log_url}job-output.txt" \
      | grep -n -B2 -A5 -iE '\| (ERROR|FAILED)\b|fatal:|failed: [1-9]' \
      | sed -E 's/^[0-9]+:[0-9-]+ [0-9:.]+ \| ?/  /' \
      | tail -60
    echo
  done <<< "$FAILED_LOGS"
fi
