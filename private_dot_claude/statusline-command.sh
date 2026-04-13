#!/usr/bin/env bash
input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

# Git branch (skip optional locks)
branch=""
if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$dir" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" -c core.fsmonitor=false rev-parse --short HEAD 2>/dev/null)
    [ -n "$branch" ] && branch=" ($branch)"
fi

model_raw=$(echo "$input" | jq -r '.model.id // empty')

# Resolve the human-readable model name.
# When the ID is an AWS Bedrock ARN, the name/version substrings are not
# embedded in it, so we call the Bedrock API once and cache the result.
resolve_model_name() {
    local arn="$1"
    local cache_dir="${HOME}/.claude/cache"
    mkdir -p "$cache_dir"
    # Use a filename-safe hash of the ARN as the cache key.
    local cache_key
    cache_key=$(printf '%s' "$arn" | md5 2>/dev/null || printf '%s' "$arn" | md5sum 2>/dev/null | awk '{print $1}')
    local today
    today=$(date +%Y-%m-%d)
    local cache_file="${cache_dir}/bedrock-profile-${cache_key}-${today}.txt"
    # Remove stale cache files for this ARN hash from previous days.
    find "$cache_dir" -maxdepth 1 -name "bedrock-profile-${cache_key}-*.txt" \
        ! -name "bedrock-profile-${cache_key}-${today}.txt" -delete 2>/dev/null
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
        return
    fi
    # Fetch the inference profile and pull the first model ID from the models array.
    local resolved
    resolved=$(aws bedrock get-inference-profile \
        --inference-profile-identifier "$arn" \
        --output json 2>/dev/null \
        | jq -r '.models[0].modelArn // .inferenceProfileArn // empty')
    if [ -z "$resolved" ]; then
        # Fallback: use the raw ARN itself, but don't cache it
        # so we retry next time.
        printf '%s' "$arn"
        return
    fi
    printf '%s' "$resolved" > "$cache_file"
    printf '%s' "$resolved"
}

# Decide whether to use the display_name (non-ARN path) or resolve via API.
display_name=$(echo "$input" | jq -r '.model.display_name // empty')
if [[ "$model_raw" == arn:aws:* ]]; then
    model_resolved=$(resolve_model_name "$model_raw")
else
    # For non-ARN IDs fall back to display_name, then the raw ID.
    model_resolved="${display_name:-$model_raw}"
fi

# Extract the bare model name from the resolved ARN or use as-is.
# Handles foundation-model/, model/, inference-profile/, and other ARN path segments.
model_with_suffix=$(echo "$model_resolved" | sed 's|.*/||')
model=$(echo "$model_with_suffix" | sed 's|\[.*\]$||')
ctx_size=$(echo "$model_with_suffix" | sed -n 's|.*\[\(.*\)\]$|\1|p')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

printf '\033[1;34m%s\033[0m\033[0;33m%s\033[0m' \
    "$dir" "$branch"
if [ -n "$model" ]; then
    if [ -n "$ctx_size" ]; then
        printf ' \033[0;36m[%s %s]\033[0m' "$model" "$ctx_size"
    else
        printf ' \033[0;36m[%s]\033[0m' "$model"
    fi
fi
if [ -n "$used" ]; then
    used_int=$(printf '%.0f' "$used")
    if [ "$used_int" -ge 80 ]; then
        ctx_color='\033[0;31m'
    elif [ "$used_int" -ge 50 ]; then
        ctx_color='\033[0;33m'
    else
        ctx_color='\033[0;32m'
    fi
    printf " ${ctx_color}[ctx: %s%%]\033[0m" "$used_int"
fi
printf '\n'
