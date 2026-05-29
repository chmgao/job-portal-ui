#!/bin/sh
# Claude Code status line: model name + context usage with color-coded progress bar
# Located in project: job-portal-ui/.claude/statusline.sh

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ANSI color codes
RESET="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
BOLD="\033[1m"

if [ -z "$used" ]; then
  printf "${BOLD}%s${RESET}  [----------] awaiting first message" "$model"
  exit 0
fi

used_int=$(printf "%.0f" "$used")
remaining=$(( 100 - used_int ))

# Build progress bar (20 chars wide)
BAR_WIDTH=20
filled=$(( used_int * BAR_WIDTH / 100 ))
empty=$(( BAR_WIDTH - filled ))

bar=""
i=0
while [ $i -lt $filled ]; do
  bar="${bar}#"
  i=$(( i + 1 ))
done
while [ $i -lt $BAR_WIDTH ]; do
  bar="${bar}-"
  i=$(( i + 1 ))
done

# Pick bar color based on usage level
if [ "$used_int" -ge 85 ]; then
  BAR_COLOR="$RED"
elif [ "$used_int" -ge 60 ]; then
  BAR_COLOR="$YELLOW"
else
  BAR_COLOR="$GREEN"
fi

printf "${BOLD}%s${RESET}  ${BAR_COLOR}[%s]${RESET} %d%% used (%d%% remaining)" \
  "$model" "$bar" "$used_int" "$remaining"
