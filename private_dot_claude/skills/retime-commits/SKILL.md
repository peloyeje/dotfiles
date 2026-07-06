---
name: retime-commits
description: Rewrite the author and committer dates of commits on the current git branch so they fall within a chosen period and daily working-hour windows (default business hours 9am-12pm and 2pm-7pm), preserving commit order. Use whenever the user wants to retime, re-date, backdate, redistribute, or "make commits look like" they happened during work hours or on specific days, or mentions cleaning up commit timestamps before pushing. Explicitly invoked - never retime history on your own initiative.
argument-hint: [period, e.g. "last week" or "2026-07-01 to 2026-07-03"]
---

# Retime Commits

Rewrite commit timestamps on the current branch so they land inside a chosen calendar period and within daily working-hour windows, while keeping the commits in their original chronological order. This is useful for tidying up a branch (e.g. commits made late at night or bunched into a few minutes) so the history reads as steady work across business days before it gets pushed.

Rewriting history changes commit SHAs. That is safe for un-pushed or personal branches, but for shared branches it forces a `--force-with-lease` push that teammates must reconcile. Because of that, this skill **never pushes** and always leaves a backup branch. Only run it when the user explicitly asks to retime/re-date commits.

The heavy lifting lives in `scripts/retime_commits.py`, which has two subcommands: `plan` (read-only preview) and `apply` (the rewrite). Always run `plan` first and show the user the preview, because a timestamp rewrite is easy to get subtly wrong (wrong range, wrong period, out-of-order) and much easier to catch by eye before applying than after.

## Step 1: Establish the period

The period is the calendar span the commits should be spread across. The user usually gives it in words ("last week", "yesterday afternoon", "between the 1st and 3rd"). Convert that to concrete `--start` and `--end` dates. If the user hasn't given a period, ask for one - don't guess, since the whole point is to place commits where the user wants them.

Resolve relative phrases against today's date, which you can get from the environment. A bare date like `2026-07-03` means the whole day.

The daily working-hour windows default to `09:00-12:00,14:00-19:00` (business hours with a lunch break). Only change `--windows` if the user asks for different hours (e.g. "evenings only", "9 to 5 no lunch"). Weekends are skipped by default; pass `--include-weekends` only if the user wants Saturday/Sunday included.

## Step 2: Confirm the commit range

By default the script retimes every commit since the current branch diverged from the main branch (`<merge-base with origin/main or main/master>..HEAD`). This is usually exactly what the user means by "this branch's commits."

Before planning, get your bearings so you can confirm the range is right:

```bash
git log --format='%h %ai %s' <merge-base>..HEAD   # or just: git log --oneline -20
```

If the user wants a different set (e.g. only the last 3 commits, or a range that includes already-pushed commits), pass an explicit `--range` such as `--range HEAD~3..HEAD`. Flag it clearly if the range includes commits that are already on the remote, since retiming those means a force-push that rewrites shared history.

This tool assumes linear history. If the range contains merge commits, the script warns you - stop and check with the user rather than reshaping the graph.

## Step 3: Plan (preview)

Run the plan subcommand. It touches nothing in the repo - it only computes new timestamps and writes a plan file.

```bash
python scripts/retime_commits.py plan --start 2026-07-01 --end 2026-07-03
```

Add `--windows`, `--include-weekends`, or `--range` as needed. By default the plan is written to `<git-dir>/retime-plan.json` (i.e. inside the repo's own `.git/`). Let it use that default rather than passing `--out /tmp/...`: a fixed shared path like `/tmp/retime-plan.json` can silently pick up a stale plan from an earlier run or another repo, and then `apply` would rewrite history using the wrong plan. The repo-scoped default sidesteps that entirely. The command prints the exact path it wrote.

The command prints a table mapping each commit to its new date alongside its old date. Show this preview to the user and let them confirm before applying. If they want a different random layout, rerun `plan` (each run uses a fresh random seed unless you pass `--seed`); to reproduce an exact layout later, note the seed it printed.

## Step 4: Apply

Once the user is happy with the preview, apply the plan file that `plan` just wrote - pass the exact path it printed.

```bash
python scripts/retime_commits.py apply --plan <path printed by plan> --yes
```

`apply` prints which plan it is about to run (path, range, period, commit count), then re-checks that the plan describes exactly the commits currently in its range. If the plan is stale or was built for a different range or repo, this check fails and nothing is rewritten - regenerate the plan in that case rather than forcing it. When the check passes it creates a backup branch (`backup/retime/<branch>`), rewrites author + committer dates for exactly the planned commits, and verifies the result is chronological.

`--yes` skips the script's own interactive confirmation, which is appropriate here because the user already reviewed the preview in Step 3. Omit it if you want the script to prompt again. Always read the "Applying plan" banner it prints - if the range or period isn't what you intended, stop.

## Step 5: Report and hand off the push

After applying, tell the user:

- The rewrite is done and timestamps are verified in order.
- Where the backup is (`backup/retime/<branch>`) and how to undo: `git reset --hard backup/retime/<branch>`.
- The exact push command the script printed, if the branch has an upstream. **Do not push yourself** unless the user explicitly asks - publishing rewritten history is their call, and `--force-with-lease` overwrites the remote.

To confirm the final result:

```bash
git log --format='%h %ai %s' <range>
```

## Notes

- Author and committer dates are set to the same value so the timestamps are internally consistent.
- Timestamps use the machine's local timezone (DST-aware), so they look like natural local work times.
- If the period contains no working time (e.g. a single weekend with weekends disabled), the script stops and asks you to widen the period or windows - relay that to the user rather than forcing a bad layout.
