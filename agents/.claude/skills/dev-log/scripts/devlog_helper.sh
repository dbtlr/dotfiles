#!/bin/bash

# Dev Log Helper Script (Global)
# Gathers environmental information for creating per-session dev log entries.
# Non-interactive: outputs key=value lines for Claude to parse.
# Log destination: ~/data/vaults/Life Lab/Log/ (flat, no weekly subdirs)

# 1. Timestamp
TIMESTAMP=$(date "+%Y-%m-%dT%H:%M%z")
echo "TIMESTAMP: $TIMESTAMP"

# 2. Date components
FILE_DATE=$(date "+%Y-%m-%d")
FILE_TIME=$(date "+%H%M")
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

# 4. Project name from CLAUDE.local.md
PROJECT_NAME=""
if [ -n "$GIT_ROOT" ] && [ -f "$GIT_ROOT/CLAUDE.local.md" ]; then
  PROJECT_NAME=$(grep -m1 '^vault_project:' "$GIT_ROOT/CLAUDE.local.md" 2>/dev/null | sed 's/^vault_project: *//' | xargs)
fi

if [ -n "$PROJECT_NAME" ] && [ "$PROJECT_NAME" != "none" ]; then
  PROJECT_CONTEXT_PATH="$HOME/data/vaults/Life Lab/Projects/$PROJECT_NAME/context.md"
  echo "PROJECT_NAME: $PROJECT_NAME"
  echo "PROJECT_CONTEXT_PATH: $PROJECT_CONTEXT_PATH"
else
  echo "PROJECT_NAME: (none)"
  echo "PROJECT_CONTEXT_PATH: (none)"
fi

# 5. Log directory (flat)
LOG_DIR="$HOME/data/vaults/Life Lab/Log"
echo "LOG_DIR: $LOG_DIR"

# Create log directory if needed
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
  echo "LOG_DIR_CREATED: true"
fi

# 6. List recent sessions (last 10)
echo "RECENT_SESSIONS:"
if [ -d "$LOG_DIR" ]; then
  ls -1t "$LOG_DIR" 2>/dev/null | head -10 | while read -r session; do
    echo "  - $session"
  done
fi

# 7. Find most recent previous session
PREV_SESSION_PATH=""
LATEST=$(ls -t "$LOG_DIR" 2>/dev/null | head -1)

if [ -n "$LATEST" ]; then
  PREV_SESSION_PATH="$LOG_DIR/$LATEST"
fi

if [ -n "$PREV_SESSION_PATH" ] && [ -f "$PREV_SESSION_PATH" ]; then
  echo "PREVIOUS_SESSION_PATH: $PREV_SESSION_PATH"
  echo "READ_PREVIOUS_SESSION: true"
else
  echo "READ_PREVIOUS_SESSION: false"
fi

# 8. Same-day sessions
echo "SAME_DAY_SESSIONS:"
if [ -d "$LOG_DIR" ]; then
  ls -1 "$LOG_DIR" 2>/dev/null | grep "^${FILE_DATE}" | while read -r session; do
    echo "  - $LOG_DIR/$session"
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
echo "SESSION_FILE_PATH will be: ${LOG_DIR}/[filename]"

echo ""
echo "=== Loading Recommendations ==="
echo "LOAD_PREVIOUS: true (always load immediately previous session)"
if [ -n "$(ls -1 "$LOG_DIR" 2>/dev/null | grep "^${FILE_DATE}")" ]; then
  echo "LOAD_SAME_DAY: true (found other sessions from today)"
fi

echo ""
echo "DEVLOG_HELPER_COMPLETE"
