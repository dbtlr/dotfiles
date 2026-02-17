#!/bin/bash

# Dev Log Helper Script (Global)
# Gathers environmental information for creating per-session dev log entries.
# Non-interactive: outputs key=value lines for Claude to parse.
# Log destination: ~/vaults/agents/log/ (global, not project-relative)

# 1. Timestamp
TIMESTAMP=$(date "+%Y-%m-%dT%H:%M%z")
echo "TIMESTAMP: $TIMESTAMP"

# 2. Week/date components
WEEK=$(date "+%V")
YEAR=$(date "+%Y")
FILE_DATE=$(date "+%Y-%m-%d")
FILE_TIME=$(date "+%H%M")
echo "WEEK: $WEEK"
echo "YEAR: $YEAR"
echo "FILE_DATE: $FILE_DATE"
echo "FILE_TIME: $FILE_TIME"

# 3. Git repo detection
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
GIT_REPO=$(basename "$GIT_ROOT" 2>/dev/null || echo "")
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
GIT_DIFF_STAT=$(git diff --stat HEAD 2>/dev/null | tail -1 || echo "")
echo "GIT_REPO: $GIT_REPO"
echo "GIT_BRANCH: $GIT_BRANCH"
echo "GIT_DIFF_STAT: $GIT_DIFF_STAT"

# 4. Project manifest path (auto-derived from repo name)
if [ -n "$GIT_REPO" ]; then
  PROJECT_MANIFEST_PATH="$HOME/vaults/agents/knowledge/projects/${GIT_REPO}.md"
  echo "PROJECT_MANIFEST_PATH: $PROJECT_MANIFEST_PATH"
else
  echo "PROJECT_MANIFEST_PATH: (none — not in a git repo)"
fi

# 5. Log directory setup
LOG_DIR="$HOME/vaults/agents/log"
WEEK_DIR="$LOG_DIR/${YEAR}_w${WEEK}"
echo "LOG_DIR: $LOG_DIR"
echo "WEEK_DIR: $WEEK_DIR"

# Create week directory if needed
if [ ! -d "$WEEK_DIR" ]; then
  mkdir -p "$WEEK_DIR"
  echo "WEEK_DIR_CREATED: true"
else
  echo "WEEK_DIR_EXISTS: true"
fi

# 6. List existing sessions this week
echo "CURRENT_WEEK_SESSIONS:"
if [ -d "$WEEK_DIR" ]; then
  ls -1 "$WEEK_DIR" 2>/dev/null | while read -r session; do
    echo "  - $session"
  done
fi

# 7. Find most recent previous session (across all weeks)
PREV_SESSION_PATH=""
LATEST_IN_WEEK=""

if [ -d "$WEEK_DIR" ]; then
  LATEST_IN_WEEK=$(ls -t "$WEEK_DIR" 2>/dev/null | head -1)
fi

if [ -n "$LATEST_IN_WEEK" ]; then
  PREV_SESSION_PATH="$WEEK_DIR/$LATEST_IN_WEEK"
else
  # Check previous week directories
  for week_dir in $(ls -dt "$LOG_DIR"/????_w?? 2>/dev/null); do
    if [ "$week_dir" != "$WEEK_DIR" ]; then
      LATEST=$(ls -t "$week_dir" 2>/dev/null | head -1)
      if [ -n "$LATEST" ]; then
        PREV_SESSION_PATH="$week_dir/$LATEST"
        break
      fi
    fi
  done
fi

if [ -n "$PREV_SESSION_PATH" ] && [ -f "$PREV_SESSION_PATH" ]; then
  echo "PREVIOUS_SESSION_PATH: $PREV_SESSION_PATH"
  echo "READ_PREVIOUS_SESSION: true"
else
  echo "READ_PREVIOUS_SESSION: false"
fi

# 8. Same-day sessions
echo "SAME_DAY_SESSIONS:"
if [ -d "$WEEK_DIR" ]; then
  ls -1 "$WEEK_DIR" 2>/dev/null | grep "^${FILE_DATE}" | while read -r session; do
    echo "  - $WEEK_DIR/$session"
  done
fi

# 9. Branch-based issue hint (extract PROJ-NNN pattern from branch name)
if [ -n "$GIT_BRANCH" ]; then
  ISSUE_HINT=$(echo "$GIT_BRANCH" | grep -oE '[A-Z]+-[0-9]+' | tr '\n' '_' | sed 's/_$//')
  if [ -n "$ISSUE_HINT" ]; then
    echo "ISSUE_HINT: $ISSUE_HINT"
  fi
fi

# 10. Filename guidance
echo ""
echo "=== Filename Construction ==="
echo "Claude should determine from conversation context:"
echo "  DESCRIPTION: Brief 3-5 word description (lowercase, hyphens, e.g. 'add-auth-middleware')"
echo "  ISSUES: Issue IDs if applicable (uppercase, underscores, e.g. 'PROJ-42' or 'PROJ-42_PROJ-43')"
echo ""
echo "Filename format:"
echo "  With issues:    ${FILE_DATE}_${FILE_TIME}_ISSUES_DESCRIPTION.md"
echo "  Without issues: ${FILE_DATE}_${FILE_TIME}_DESCRIPTION.md"
echo ""
echo "SESSION_FILE_PATH will be: ${WEEK_DIR}/[filename]"

echo ""
echo "=== Loading Recommendations ==="
echo "LOAD_PREVIOUS: true (always load immediately previous session)"
if [ -n "$(ls -1 "$WEEK_DIR" 2>/dev/null | grep "^${FILE_DATE}")" ]; then
  echo "LOAD_SAME_DAY: true (found other sessions from today)"
fi

echo ""
echo "DEVLOG_HELPER_COMPLETE"
