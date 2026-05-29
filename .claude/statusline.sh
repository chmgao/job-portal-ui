#!/bin/sh
# Claude Code status line: model name + context usage with progress bar
# Located in project: job-portal-ui/.claude/statusline.sh

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -z "$used" ]; then
  printf "%s  [----------] no data" "$model"
  exit 0
fi

used_int=$(printf "%.0f" "$used")
filled=$(( used_int / 10 ))
empty=$(( 10 - filled ))

bar=""
i=0
while [ $i -lt $filled ]; do
  bar="${bar}#"
  i=$(( i + 1 ))
done
while [ $i -lt 10 ]; do
  bar="${bar}-"
  i=$(( i + 1 ))
done

printf "%s  [%s] %d%% used" "$model" "$bar" "$used_int"
