#!/bin/sh
# Claude Code status line — styled after the robbyrussell Oh My Zsh theme

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Git info (branch from worktree or repo)
git_branch=""
worktree_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
if [ -n "$worktree_branch" ]; then
  git_branch="$worktree_branch"
elif [ -n "$cwd" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi

# Context usage
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Rate limits
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ANSI colors
GREEN='\033[1;32m'
CYAN='\033[0;36m'
BLUE='\033[1;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Arrow (always green since we have no exit code here)
printf "${GREEN}➜${RESET} "

# Current directory (cyan)
printf "${CYAN}%s${RESET}" "$dir"

# Git branch (blue prefix, red branch name)
if [ -n "$git_branch" ]; then
  printf " ${BLUE}git:(${RED}%s${BLUE})${RESET}" "$git_branch"
fi

# Model name
if [ -n "$model" ]; then
  printf " ${YELLOW}[%s]${RESET}" "$model"
fi

# Context remaining
if [ -n "$remaining" ]; then
  printf " ${CYAN}ctx:%.0f%%${RESET}" "$remaining"
fi

# Session (5h) and 7-day usage
if [ -n "$five_hour_pct" ]; then
  printf " ${MAGENTA}ses:%.0f%%${RESET}" "$five_hour_pct"
fi
if [ -n "$seven_day_pct" ]; then
  printf " ${YELLOW}7d:%.0f%%${RESET}" "$seven_day_pct"
fi

printf "\n"
