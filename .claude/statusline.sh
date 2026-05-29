#!/bin/sh
# Claude Code status line: model name, cwd, git branch, context usage with color-coded progress bar
# Located in project: job-portal-ui/.claude/statusline.sh

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Git branch (skip lock files to avoid blocking)
git_branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -z "$git_branch" ]; then
  git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# ANSI color codes
RESET="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
BOLD="\033[1m"
DIM="\033[2m"

if [ -z "$used" ]; then
  if [ -n "$git_branch" ]; then
    printf "${BOLD}${CYAN}%s${RESET}  ${DIM}%s${RESET}  ${BOLD}${CYAN}%s${RESET}  ${DIM}[--------------------]${RESET}  ${DIM}no messages yet${RESET}" \
      "$model" "$cwd" "$git_branch"
  else
    printf "${BOLD}${CYAN}%s${RESET}  ${DIM}%s${RESET}  ${DIM}[--------------------]${RESET}  ${DIM}no messages yet${RESET}" \
      "$model" "$cwd"
  fi
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
  bar="${bar}█"
  i=$(( i + 1 ))
done
i=0
while [ $i -lt $empty ]; do
  bar="${bar}░"
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

if [ -n "$git_branch" ]; then
  printf "${BOLD}${CYAN}%s${RESET}  ${DIM}%s${RESET}  ${BOLD}${CYAN}%s${RESET}  ${BAR_COLOR}%s${RESET}  ${BOLD}%d%%${RESET} ${DIM}used  %d%% left${RESET}" \
    "$model" "$cwd" "$git_branch" "$bar" "$used_int" "$remaining"
else
  printf "${BOLD}${CYAN}%s${RESET}  ${DIM}%s${RESET}  ${BAR_COLOR}%s${RESET}  ${BOLD}%d%%${RESET} ${DIM}used  %d%% left${RESET}" \
    "$model" "$cwd" "$bar" "$used_int" "$remaining"
fi
