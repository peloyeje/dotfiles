#!/usr/bin/env python3
"""Retime a linear range of git commits into random business-hour timestamps.

Two subcommands keep "what you preview" identical to "what you apply":

  plan   Compute new timestamps and write a plan file (JSON). Never touches the
         repo. Prints a human-readable preview table.
  apply  Read a plan file, create a backup branch, and rewrite author+committer
         dates for exactly those commits. Never pushes.

Chronological order of commits is always preserved. Timestamps land only inside
the given daily windows (default business hours 09:00-12:00 and 14:00-19:00),
on weekdays only unless --include-weekends is passed, and inside the requested
period. Times are emitted in the machine's local timezone so they look natural.
"""

from __future__ import annotations

import argparse
import json
import os
import random
import subprocess
import sys
from datetime import datetime, timedelta


# --------------------------------------------------------------------------- #
# git helpers
# --------------------------------------------------------------------------- #
def git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args], capture_output=True, text=True, check=True
    )
    return result.stdout.strip()


def detect_base() -> str:
    """Best-effort detection of the main development branch to diverge from."""
    # Prefer the remote's default branch (origin/HEAD -> origin/main).
    try:
        ref = git("symbolic-ref", "refs/remotes/origin/HEAD")
        return ref.replace("refs/remotes/", "", 1)
    except subprocess.CalledProcessError:
        pass
    for candidate in ("origin/main", "origin/master", "main", "master"):
        try:
            git("rev-parse", "--verify", "--quiet", candidate)
            return candidate
        except subprocess.CalledProcessError:
            continue
    raise SystemExit(
        "Could not detect a base branch (main/master). Pass --range explicitly, "
        "e.g. --range origin/main..HEAD"
    )


def resolve_range(range_arg: str | None) -> tuple[str, list[dict]]:
    """Return (range_expr, commits oldest->newest). Each commit is a dict."""
    if range_arg:
        range_expr = range_arg
    else:
        base = detect_base()
        merge_base = git("merge-base", "HEAD", base)
        range_expr = f"{merge_base}..HEAD"

    # %H sha, %an author name, %aI author date ISO, %s subject
    fmt = "%H%x1f%an%x1f%aI%x1f%s"
    out = git("log", "--reverse", f"--format={fmt}", range_expr)
    commits: list[dict] = []
    if out:
        for line in out.splitlines():
            sha, author, adate, subject = line.split("\x1f")
            commits.append(
                {"sha": sha, "author": author, "old_date": adate, "subject": subject}
            )
    return range_expr, commits


def has_merges(range_expr: str) -> bool:
    out = git("rev-list", "--merges", range_expr)
    return bool(out.strip())


def default_plan_path() -> str:
    """A plan path scoped to this repo, so concurrent runs in different repos
    (or a stale file from a past run) can never collide on a shared /tmp name.
    Lives inside .git/, which is already local and gitignored."""
    try:
        git_dir = git("rev-parse", "--absolute-git-dir")
        return os.path.join(git_dir, "retime-plan.json")
    except subprocess.CalledProcessError:
        return "retime-plan.json"


# --------------------------------------------------------------------------- #
# time math
# --------------------------------------------------------------------------- #
def parse_windows(spec: str) -> list[tuple[int, int]]:
    """'9-12,14-19' or '09:00-12:00,14:00-19:00' -> [(540, 720), (840, 1140)]."""
    windows: list[tuple[int, int]] = []
    for chunk in spec.split(","):
        chunk = chunk.strip()
        if not chunk:
            continue
        start_s, end_s = chunk.split("-")
        start_m = _to_minutes(start_s)
        end_m = _to_minutes(end_s)
        if end_m <= start_m:
            raise SystemExit(f"Window '{chunk}' ends at or before it starts.")
        windows.append((start_m, end_m))
    windows.sort()
    return windows


def _to_minutes(token: str) -> int:
    token = token.strip()
    if ":" in token:
        h, m = token.split(":")
        return int(h) * 60 + int(m)
    return int(token) * 60


def parse_bound(token: str, *, end: bool) -> datetime:
    """Accept a date (YYYY-MM-DD) or a full datetime. Naive = local time."""
    token = token.strip()
    for fmt in ("%Y-%m-%dT%H:%M:%S", "%Y-%m-%d %H:%M:%S", "%Y-%m-%dT%H:%M", "%Y-%m-%d %H:%M"):
        try:
            return datetime.strptime(token, fmt)
        except ValueError:
            continue
    try:
        d = datetime.strptime(token, "%Y-%m-%d")
    except ValueError:
        raise SystemExit(
            f"Could not parse date/time '{token}'. Use YYYY-MM-DD or "
            "YYYY-MM-DDTHH:MM."
        )
    # A bare date means the whole day.
    return d.replace(hour=23, minute=59, second=59) if end else d


def business_intervals(
    start: datetime,
    end: datetime,
    windows: list[tuple[int, int]],
    include_weekends: bool,
) -> list[tuple[datetime, datetime]]:
    """Concrete datetime intervals inside [start, end] that fall in the windows."""
    intervals: list[tuple[datetime, datetime]] = []
    day = start.date()
    last = end.date()
    while day <= last:
        dt_day = datetime(day.year, day.month, day.day)
        is_weekend = dt_day.weekday() >= 5
        if include_weekends or not is_weekend:
            for start_m, end_m in windows:
                w_start = dt_day + timedelta(minutes=start_m)
                w_end = dt_day + timedelta(minutes=end_m)
                # Clip to the requested period bounds.
                lo = max(w_start, start)
                hi = min(w_end, end)
                if hi > lo:
                    intervals.append((lo, hi))
        day += timedelta(days=1)
    return intervals


def sample_times(
    intervals: list[tuple[datetime, datetime]], n: int, rng: random.Random
) -> list[datetime]:
    """n random datetimes uniformly across the intervals, sorted, strictly increasing."""
    if n == 0:
        return []
    durations = [(hi - lo).total_seconds() for lo, hi in intervals]
    total = sum(durations)
    if total <= 0:
        raise SystemExit(
            "The chosen period contains no business time. Widen the period or "
            "the daily windows (or pass --include-weekends)."
        )
    # Cumulative boundaries for offset -> datetime mapping.
    cum: list[float] = []
    running = 0.0
    for d in durations:
        running += d
        cum.append(running)

    def offset_to_dt(offset: float) -> datetime:
        for idx, boundary in enumerate(cum):
            if offset < boundary:
                lo, _ = intervals[idx]
                prev = cum[idx - 1] if idx > 0 else 0.0
                return lo + timedelta(seconds=offset - prev)
        lo, hi = intervals[-1]
        return hi

    picks = sorted(offset_to_dt(rng.uniform(0, total)) for _ in range(n))

    # Enforce strictly increasing (>=1s apart) so no two commits collide.
    for i in range(1, len(picks)):
        if picks[i] <= picks[i - 1]:
            picks[i] = picks[i - 1] + timedelta(seconds=1)
    return picks


def to_git_date(naive_local: datetime) -> str:
    """Attach the local tz offset (DST-aware for that date) -> git-friendly ISO."""
    aware = naive_local.astimezone()
    return aware.strftime("%Y-%m-%dT%H:%M:%S%z")


# --------------------------------------------------------------------------- #
# subcommands
# --------------------------------------------------------------------------- #
def cmd_plan(args: argparse.Namespace) -> int:
    range_expr, commits = resolve_range(args.range)
    if not commits:
        print(f"No commits found in range '{range_expr}'. Nothing to retime.")
        return 1

    if has_merges(range_expr):
        print(
            f"WARNING: range '{range_expr}' contains merge commits. This tool is "
            "built for linear history; rewriting merges can reshape the graph. "
            "Review carefully before applying.\n"
        )

    windows = parse_windows(args.windows)
    start = parse_bound(args.start, end=False)
    end = parse_bound(args.end, end=True)
    if end <= start:
        raise SystemExit("--end must be after --start.")

    seed = args.seed if args.seed is not None else random.randrange(1 << 30)
    rng = random.Random(seed)

    intervals = business_intervals(start, end, windows, args.include_weekends)
    new_times = sample_times(intervals, len(commits), rng)

    plan = {
        "range": range_expr,
        "period": {"start": start.isoformat(), "end": end.isoformat()},
        "windows": args.windows,
        "include_weekends": args.include_weekends,
        "seed": seed,
        "commits": [],
    }
    for commit, new_dt in zip(commits, new_times):
        plan["commits"].append(
            {
                "sha": commit["sha"],
                "subject": commit["subject"],
                "old_date": commit["old_date"],
                "new_date": to_git_date(new_dt),
            }
        )

    _print_preview(plan)

    out_path = args.out if args.out else default_plan_path()
    with open(out_path, "w") as f:
        json.dump(plan, f, indent=2)
    print(f"\nPlan written to {out_path}")
    print(
        "Review the preview above. To apply:\n"
        f"  python {os.path.abspath(__file__)} apply --plan {out_path}"
    )
    return 0


def _print_preview(plan: dict) -> None:
    print(f"Range : {plan['range']}")
    print(f"Period: {plan['period']['start']}  ->  {plan['period']['end']}")
    print(
        f"Windows: {plan['windows']}   "
        f"weekends: {'yes' if plan['include_weekends'] else 'no'}   "
        f"seed: {plan['seed']}"
    )
    print(f"Commits: {len(plan['commits'])}\n")
    print(f"{'#':>3}  {'new date':<25}  {'was':<25}  subject")
    print("-" * 90)
    for i, c in enumerate(plan["commits"], 1):
        subject = c["subject"][:44]
        print(f"{i:>3}  {c['new_date']:<25}  {c['old_date']:<25}  {subject}")


def cmd_apply(args: argparse.Namespace) -> int:
    with open(args.plan) as f:
        plan = json.load(f)

    commits = plan["commits"]
    if not commits:
        print("Plan has no commits. Nothing to do.")
        return 1

    # Always echo which plan is about to run, even under --yes. A rewrite driven
    # by the wrong plan file (stale, or from another repo) is the easiest way for
    # this tool to do damage, so make the plan's identity impossible to miss in
    # the transcript before anything is touched.
    print(f"Applying plan: {os.path.abspath(args.plan)}")
    print(f"  range : {plan['range']}")
    print(f"  period: {plan['period']['start']} -> {plan['period']['end']}")
    print(f"  commits: {len(commits)}  (seed {plan.get('seed', '?')})")

    # Safety: the plan must describe exactly the commits currently at the tip of
    # its range. Comparing the exact set (not just "is a subset") catches a plan
    # built for a different range or an out-of-date history, which a subset check
    # would silently accept.
    current_shas = git("rev-list", plan["range"]).splitlines()
    plan_shas = [c["sha"] for c in commits]
    if set(plan_shas) != set(current_shas):
        raise SystemExit(
            f"The plan does not match the current '{plan['range']}' history "
            f"(plan has {len(plan_shas)} commits, range currently has "
            f"{len(current_shas)}). This usually means the plan is stale or was "
            "built for a different range/repo. Regenerate the plan and try again."
        )

    if not args.yes:
        _print_preview(plan)
        reply = input("\nRewrite these commits? Type 'yes' to proceed: ").strip()
        if reply.lower() != "yes":
            print("Aborted. No changes made.")
            return 1

    # Backup the current branch tip so the rewrite is trivially reversible.
    branch = git("rev-parse", "--abbrev-ref", "HEAD")
    backup = f"backup/retime/{branch}"
    head = git("rev-parse", "HEAD")
    git("update-ref", f"refs/heads/{backup}", head)
    print(f"Backup branch created: {backup} -> {head[:12]}")

    # Build the env-filter that maps each SHA to its new author+committer date.
    clauses = []
    for c in commits:
        clauses.append(
            f'if test "$GIT_COMMIT" = "{c["sha"]}"; then '
            f'export GIT_AUTHOR_DATE="{c["new_date"]}"; '
            f'export GIT_COMMITTER_DATE="{c["new_date"]}"; fi'
        )
    env_filter = "\n".join(clauses)

    env = dict(os.environ, FILTER_BRANCH_SQUELCH_WARNING="1")
    proc = subprocess.run(
        [
            "git",
            "filter-branch",
            "-f",
            "--env-filter",
            env_filter,
            "--",
            plan["range"],
        ],
        env=env,
    )
    if proc.returncode != 0:
        raise SystemExit(
            "git filter-branch failed. Your branch is unchanged on the backup "
            f"ref {backup}. Restore with: git reset --hard {backup}"
        )

    _verify_chronology(plan["range"])

    upstream = _upstream()
    print("\nDone. History rewritten.")
    print(f"Backup kept at: {backup} (delete with: git branch -D {backup})")
    if upstream:
        print("\nThis rewrote already-tracked history. To publish, run:")
        print(f"  git push --force-with-lease {upstream.replace('/', ' ', 1)}")
    else:
        print("\nBranch has no upstream yet; push normally when ready.")
    return 0


def _verify_chronology(range_expr: str) -> None:
    dates = git("log", "--format=%at", range_expr).splitlines()
    times = [int(x) for x in dates]
    # git log is newest->oldest; expect non-increasing timestamps.
    if any(times[i] < times[i + 1] for i in range(len(times) - 1)):
        print(
            "WARNING: resulting commit timestamps are not monotonic. Inspect with "
            "`git log --format='%h %ai %s'`."
        )
    else:
        print("Verified: commit timestamps are in chronological order.")


def _upstream() -> str | None:
    try:
        return git("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}")
    except subprocess.CalledProcessError:
        return None


# --------------------------------------------------------------------------- #
# cli
# --------------------------------------------------------------------------- #
def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description=__doc__)
    sub = p.add_subparsers(dest="command", required=True)

    common_period = argparse.ArgumentParser(add_help=False)
    common_period.add_argument(
        "--start", required=True, help="Period start (YYYY-MM-DD or YYYY-MM-DDTHH:MM)"
    )
    common_period.add_argument(
        "--end", required=True, help="Period end (YYYY-MM-DD or YYYY-MM-DDTHH:MM)"
    )
    common_period.add_argument(
        "--windows",
        default="09:00-12:00,14:00-19:00",
        help="Daily windows, comma-separated (default business hours).",
    )
    common_period.add_argument(
        "--include-weekends", action="store_true", help="Allow Saturday/Sunday."
    )
    common_period.add_argument(
        "--range",
        default=None,
        help="Explicit git rev-range (default: <merge-base with main/master>..HEAD).",
    )
    common_period.add_argument("--seed", type=int, default=None, help="RNG seed.")

    plan = sub.add_parser("plan", parents=[common_period], help="Preview + write plan.")
    plan.add_argument(
        "--out",
        default=None,
        help="Plan output path (default: <git-dir>/retime-plan.json, scoped to this repo).",
    )
    plan.set_defaults(func=cmd_plan)

    apply = sub.add_parser("apply", help="Apply a plan file.")
    apply.add_argument("--plan", required=True, help="Path to a plan JSON file.")
    apply.add_argument("--yes", action="store_true", help="Skip the confirmation prompt.")
    apply.set_defaults(func=cmd_apply)

    return p


def main() -> int:
    args = build_parser().parse_args()
    try:
        return args.func(args)
    except subprocess.CalledProcessError as e:
        sys.stderr.write(f"git error: {e.stderr or e}\n")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
