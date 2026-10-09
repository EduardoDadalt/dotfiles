#!/bin/bash
# Claude Code status line
# Shows: model, effort, context used %, 5h rate limit remaining, 7d rate limit remaining

input=$(cat)

DIM="\033[2m"
RESET="\033[0m"
CYAN="\033[36m"
YELLOW="\033[33m"
MAGENTA="\033[35m"
GREEN="\033[32m"

model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

now=$(date +%s)

parts=()

segment=""
if [ -n "$model" ]; then
  segment="$(printf "${DIM}${CYAN}%s${RESET}" "$model")"
fi

if [ -n "$effort" ]; then
  effort_str="$(printf "${DIM}${CYAN}%s${RESET}" "$effort")"
  if [ -n "$segment" ]; then
    segment="${segment} ${effort_str}"
  else
    segment="$effort_str"
  fi
fi

if [ -n "$segment" ]; then
  parts+=("$segment")
fi

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    parts+=("$(printf "${DIM}${GREEN}%s${RESET}" "$branch")")
  fi
fi

if [ -n "$ctx_used" ]; then
  parts+=("$(printf "${DIM}ctx:${RESET} ${YELLOW}%.0f%%${RESET}" "$ctx_used")")
fi

if [ -n "$five_hour_used" ]; then
  five_remaining=$(awk -v u="$five_hour_used" 'BEGIN{r=100-u; if(r<0)r=0; if(r>100)r=100; printf "%.0f", r}')
  five_str="$(printf "${DIM}5h:${RESET} ${MAGENTA}%s%%${RESET}" "$five_remaining")"
  if [ -n "$five_hour_resets" ]; then
    five_ideal=$(awk -v now="$now" -v resets="$five_hour_resets" -v total=18000 'BEGIN{i=(resets-now)/total*100; if(i<0)i=0; if(i>100)i=100; printf "%.0f", i}')
    five_reset_time=$(date -d "@$five_hour_resets" +%H:%M 2>/dev/null)
    five_str="${five_str}$(printf " ${DIM}(ideal %s%%, reset %s)${RESET}" "$five_ideal" "$five_reset_time")"
  fi
  parts+=("$five_str")
fi

if [ -n "$seven_day_used" ]; then
  seven_remaining=$(awk -v u="$seven_day_used" 'BEGIN{r=100-u; if(r<0)r=0; if(r>100)r=100; printf "%.0f", r}')
  seven_str="$(printf "${DIM}7d:${RESET} ${MAGENTA}%s%%${RESET}" "$seven_remaining")"
  if [ -n "$seven_day_resets" ]; then
    seven_ideal=$(awk -v now="$now" -v resets="$seven_day_resets" -v total=604800 'BEGIN{i=(resets-now)/total*100; if(i<0)i=0; if(i>100)i=100; printf "%.0f", i}')
    seven_str="${seven_str}$(printf " ${DIM}(ideal %s%%)${RESET}" "$seven_ideal")"
  fi
  parts+=("$seven_str")
fi

IFS="$(printf '\036')"
sep=" ${DIM}|${RESET} "
output=""
first=1
for part in "${parts[@]}"; do
  if [ "$first" -eq 1 ]; then
    output="$part"
    first=0
  else
    output="${output}${sep}${part}"
  fi
done
unset IFS

printf "%b\n" "$output"
