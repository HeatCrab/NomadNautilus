#!/bin/bash
# Test hook: validates that additionalContext is injected into Claude's context

INPUT=$(cat)

# Log to file to confirm hook was called
echo "$(date): hook called with input: $INPUT" >> /tmp/hook-test.log

# Return additionalContext to Claude
echo '{
  "hookSpecificOutput": {
    "permissionDecision": "allow",
    "additionalContext": "HOOK_TEST_MARKER: This message was injected by the PreToolUse hook. If you can read this, additionalContext works correctly."
  }
}'
