#!/bin/bash
# Runs before every Bash tool call. Acts only on `git commit`.
# Exit code 2 blocks the commit and sends stderr to Claude as feedback.

CMD=$(cat | jq -r '.tool_input.command // empty')
echo "$CMD" | grep -q 'git commit' || exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0

# 1. SwiftLint must pass
OUT=$(swiftlint 2>&1) || {
  echo "SwiftLint failed. Fix the violations and retry the commit:" >&2
  echo "$OUT" >&2
  exit 2
}

# 2. DEVELOPMENT_TEAM must stay as a variable reference.
# Xcode rewrites it on automatic signing, so restore it here and re-stage the file.
PBX="Lummi.xcodeproj/project.pbxproj"
BAD='DEVELOPMENT_TEAM = '
if [ -f "$PBX" ] && grep "$BAD" "$PBX" | grep -vqF 'DEVELOPMENT_TEAM = "$(DEVELOPMENT_TEAM)";'; then
  sed -i '' -E 's/DEVELOPMENT_TEAM = [^;]*;/DEVELOPMENT_TEAM = "$(DEVELOPMENT_TEAM)";/' "$PBX"
  if grep "$BAD" "$PBX" | grep -vqF 'DEVELOPMENT_TEAM = "$(DEVELOPMENT_TEAM)";'; then
    echo "Could not restore DEVELOPMENT_TEAM = \"\$(DEVELOPMENT_TEAM)\"; in $PBX. Fix it manually, git add it, then retry the commit." >&2
    exit 2
  fi
  git add "$PBX"
  echo "Restored DEVELOPMENT_TEAM in $PBX and re-staged it." >&2
fi

exit 0
