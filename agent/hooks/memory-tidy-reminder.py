#!/usr/bin/env python3
'''
Inject a weekly tidy reminder at session start when this project's
auto-memory has gone more than 7 days without a tidy pass.

The tidy flow itself lives in the global CLAUDE.md Memory Writing
section. Finishing a tidy touches the .last-tidy marker, which resets
this reminder. The project directory name is derived from the session
cwd the same way Claude Code encodes it (every non-alphanumeric byte
becomes a dash), so a session started in a subdirectory misses the
lookup and the hook stays silent, which is acceptable since sessions
normally start at the project root.
'''

import json
import os
import re
import sys
import time


def main():
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        payload = {}
    cwd = payload.get('cwd') or os.getcwd()

    encoded = re.sub(r'[^A-Za-z0-9]', '-', cwd)
    mem_dir = os.path.expanduser(
        os.path.join('~/.claude/projects', encoded, 'memory'))
    if not os.path.isdir(mem_dir):
        return

    marker = os.path.join(mem_dir, '.last-tidy')
    week = 7 * 24 * 3600
    if os.path.exists(marker):
        if time.time() - os.path.getmtime(marker) <= week:
            return

    ctx = (
        'Weekly memory tidy is due for this project (no tidy recorded '
        'within 7 days). Before anything else, briefly tell the user that '
        "this project's memory needs tidying and wait for their decision "
        '- do not start tidying on your own. If they approve, follow the '
        'Memory Writing rules in the global CLAUDE.md (move stale files '
        'into archive/, delete archive files older than 3 months, digest '
        'and empty the Codex inbox, update the indexes), then run: '
        'touch ' + marker + ' . If they decline for now, leave the marker '
        'alone so the reminder returns next session; if they ask to '
        'snooze it for a week, touch the marker without tidying.'
    )
    print(json.dumps({
        'hookSpecificOutput': {
            'hookEventName': 'SessionStart',
            'additionalContext': ctx,
        },
    }))


main()
