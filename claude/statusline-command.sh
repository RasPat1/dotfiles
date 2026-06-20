#!/usr/bin/env bash
# Claude Code status line script
# Layout: cwd  git-branch  worktree  model  effort  ctx X% used  5h NN%  wk NN%

input=$(cat)

# --- cwd ---
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
dir=$(basename "$cwd")

# --- git branch ---
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

# --- git worktree ---
# Distinguish agents that look identical (same branch): the worktree ROOT is the
# real isolation boundary. A linked worktree (own checkout) is safe; the main
# checkout shared by multiple agents is where they can stomp on each other.
wt_name=""
wt_linked=0
wt_top=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
if [ -n "$wt_top" ]; then
  wt_name=$(basename "$wt_top")
  # Linked worktrees always have a git dir under ".../.git/worktrees/<name>".
  wt_gitdir=$(git -C "$cwd" --no-optional-locks rev-parse --git-dir 2>/dev/null)
  case "$wt_gitdir" in
    *"/worktrees/"*) wt_linked=1 ;;
  esac
fi

# --- model ---
model=$(echo "$input" | jq -r '.model.display_name // empty')

# --- effort level (optional field, only present when model supports it) ---
effort=$(echo "$input" | jq -r '.effort.level // empty')

# --- context remaining (pre-calculated, null before first message) ---
ctx_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# --- usage limits (rate_limits present only when limit data is available) ---
# 5-hour ("session") and weekly ("seven_day") limits, as percent USED.
fivehour_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
fivehour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
weekly_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
weekly_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Compact reset countdown from an epoch-seconds timestamp, e.g. "3h", "12m".
reset_eta() {
  local target="$1" now diff d h m
  [ -z "$target" ] && return
  now=$(date +%s)
  diff=$(( target - now ))
  [ "$diff" -le 0 ] && { printf 'soon'; return; }
  d=$(( diff / 86400 ))
  h=$(( (diff % 86400) / 3600 ))
  m=$(( (diff % 3600) / 60 ))
  if [ "$d" -gt 0 ]; then
    printf '%dd' "$d"
  elif [ "$h" -gt 0 ]; then
    printf '%dh' "$h"
  else
    printf '%dm' "$m"
  fi
}

# Color by how much of the limit is consumed (high used = closer to cap).
usage_color() {
  local used="$1"
  if [ "$used" -ge 80 ]; then
    printf '%s' "$RED"
  elif [ "$used" -ge 50 ]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# --- build line ---
# Colors: bold cyan for dir, yellow for branch, dim for model/effort, green/red for ctx
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
MAGENTA='\033[35m'
BLUE='\033[34m'

parts=()

# cwd
parts+=("$(printf "${BOLD}${CYAN}%s${RESET}" "$dir")")

# git branch
if [ -n "$branch" ]; then
  parts+=("$(printf "${YELLOW}%s${RESET}" "$branch")")
fi

# worktree (isolation boundary): green = own linked worktree (safe),
# yellow = main checkout (shared → stomping risk if other agents are here too)
if [ -n "$wt_name" ]; then
  if [ "$wt_linked" -eq 1 ]; then
    parts+=("$(printf "${GREEN}⑂ %s${RESET}" "$wt_name")")
  else
    parts+=("$(printf "${YELLOW}⑂ %s ${DIM}(main)${RESET}" "$wt_name")")
  fi
fi

# model
if [ -n "$model" ]; then
  parts+=("$(printf "${DIM}%s${RESET}" "$model")")
fi

# effort
if [ -n "$effort" ]; then
  parts+=("$(printf "${MAGENTA}effort:%s${RESET}" "$effort")")
fi

# context used (= 100 - remaining); high used is bad
if [ -n "$ctx_remaining" ]; then
  ctx_used=$(printf '%.0f' "$(echo "$ctx_remaining" | awk '{print 100 - $1}')")
  if [ "$ctx_used" -ge 85 ]; then
    color="$RED"
  elif [ "$ctx_used" -ge 65 ]; then
    color="$YELLOW"
  else
    color="$GREEN"
  fi
  parts+=("$(printf "${color}ctx %s%% used${RESET}" "$ctx_used")")
fi

# 5-hour usage limit
if [ -n "$fivehour_used" ]; then
  used_int=$(printf '%.0f' "$fivehour_used")
  color=$(usage_color "$used_int")
  eta=$(reset_eta "$fivehour_reset")
  if [ -n "$eta" ]; then
    parts+=("$(printf "${color}5h %s%%${RESET}${DIM} (%s)${RESET}" "$used_int" "$eta")")
  else
    parts+=("$(printf "${color}5h %s%%${RESET}" "$used_int")")
  fi
fi

# weekly usage limit
if [ -n "$weekly_used" ]; then
  used_int=$(printf '%.0f' "$weekly_used")
  color=$(usage_color "$used_int")
  eta=$(reset_eta "$weekly_reset")
  if [ -n "$eta" ]; then
    parts+=("$(printf "${color}wk %s%%${RESET}${DIM} (%s)${RESET}" "$used_int" "$eta")")
  else
    parts+=("$(printf "${color}wk %s%%${RESET}" "$used_int")")
  fi
fi

# join with separator
sep="$(printf "${DIM}  ${RESET}")"
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result}${sep}${part}"
  fi
done

printf "%s" "$result"
