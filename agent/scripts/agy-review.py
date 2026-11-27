#!/usr/bin/env python3
'''
Run one headless Antigravity review and print the response.

Plan mode refuses shell commands, so the diff is collected here and placed
in the prompt. A refused tool call ends the run with exit code 0 and an empty
response, so an empty response is reported as a failure. In a git repository
the working tree is compared before and after, because plan mode is not
documented as read-only.
'''

import argparse
import hashlib
import json
import os
import subprocess
import sys

RULES = (
    'Review only. Do not modify any file, do not run shell commands, and do '
    'not invoke sub-reviews, swarm, or other agents. '
    'Use your file reading tool if you need context from this directory. '
    'Give design-level feedback, not lint or style, most serious first.'
)
# The prompt travels as one argument. Linux caps a single argument at 128 KiB,
# macOS caps the whole command line at about one megabyte.
MAX_PROMPT = 120_000 if sys.platform.startswith('linux') else 800_000
DEFAULT_MODEL = 'gemini-4-neon-high'
DEFAULT_TIMEOUT = '20m'


def git(root, *args):
    done = subprocess.run(['git', '-C', root, *args], capture_output=True)
    if done.returncode:
        sys.exit(done.stderr.decode(errors='replace').strip())
    return done.stdout


def toplevel(root):
    probe = subprocess.run(
        ['git', '-C', root, 'rev-parse', '--show-toplevel'],
        capture_output=True, text=True)
    return None if probe.returncode else probe.stdout.strip()


def head(root):
    # A repository without commits has no HEAD, which is not an error here.
    return subprocess.run(
        ['git', '-C', root, 'rev-parse', '--verify', '-q', 'HEAD'],
        capture_output=True).stdout


def untracked(root):
    out = git(root, 'ls-files', '--others', '--exclude-standard', '-z')
    return [os.fsdecode(p) for p in out.split(b'\0') if p]


def collect_diff(root, opts):
    if opts.commit:
        return git(root, 'show', '--no-ext-diff', opts.commit)
    if opts.base:
        return git(root, 'diff', '--no-ext-diff', f'{opts.base}...HEAD')
    # A diff against HEAD hides a staged change that the working tree reverts.
    sections = [
        ('Staged changes:', git(root, 'diff', '--no-ext-diff', '--cached')),
        ('Unstaged changes:', git(root, 'diff', '--no-ext-diff')),
        ('Untracked files, read them:',
         '\n'.join(untracked(root)).encode()),
    ]
    return b'\n'.join(
        title.encode() + b'\n' + body for title, body in sections if body)


def snapshot(root):
    top = toplevel(root)
    if top is None:
        return None
    digest = hashlib.sha256(head(top))
    digest.update(git(top, 'diff', '--no-ext-diff', '--binary', '--cached'))
    digest.update(git(top, 'diff', '--no-ext-diff', '--binary'))
    digest.update(git(top, 'status', '--porcelain', '-z'))
    for name in untracked(top):
        path = os.path.join(top, name)
        if os.path.isfile(path):
            with open(path, 'rb') as f:
                digest.update(hashlib.sha256(f.read()).digest())
    return digest.hexdigest()


def build_prompt(root, opts):
    parts = [RULES, opts.prompt]
    if opts.diff or opts.base or opts.commit:
        diff = collect_diff(root, opts).decode(errors='replace').strip()
        if not diff:
            sys.exit('Nothing to review, the diff is empty.')
        parts.append('Changes under review:\n\n' + diff)
    prompt = '\n\n'.join(parts)
    if len(prompt.encode()) > MAX_PROMPT:
        sys.exit('The prompt is too long, narrow the review scope.')
    return prompt


def main():
    parser = argparse.ArgumentParser(description='Antigravity review')
    parser.add_argument('prompt')
    parser.add_argument('-C', dest='root', default='.')
    parser.add_argument('-m', '--model', default=None)
    parser.add_argument('--timeout', default=DEFAULT_TIMEOUT)
    parser.add_argument('-r', '--resume', dest='resume')
    scope = parser.add_mutually_exclusive_group()
    scope.add_argument('--diff', action='store_true')
    scope.add_argument('--base')
    scope.add_argument('--commit')
    opts = parser.parse_args()

    root = os.path.realpath(opts.root)
    if opts.diff or opts.base or opts.commit:
        # These diffs cover the whole repository, so agy has to as well.
        root = toplevel(root)
        if root is None:
            sys.exit('A diff review needs a git repository.')
    # Adding --disable-slash-commands would silently turn plan mode off.
    command = [
        'agy', '-p', build_prompt(root, opts), '--mode', 'plan',
        '--sandbox', '--output-format', 'json',
        '--print-timeout', opts.timeout,
    ]
    model = opts.model or (None if opts.resume else DEFAULT_MODEL)
    if model:
        command.extend(['--model', model])
    if opts.resume:
        command.extend(['--conversation', opts.resume])

    before = snapshot(root)
    run = subprocess.run(command, cwd=root, stdin=subprocess.DEVNULL,
                         capture_output=True, text=True)
    changed = snapshot(root) != before

    try:
        result = json.loads(run.stdout)
    except ValueError:
        result = {}
    conv_id = (result.get('conversation_id') or '').strip()
    if conv_id:
        print(f'conversation_id: {conv_id}', file=sys.stderr)
    elif result.get('status') == 'SUCCESS':
        print('WARNING conversation_id missing from agy output; '
              '--resume unavailable.', file=sys.stderr)
    response = (result.get('response') or '').strip()
    if response:
        print(response)
    if run.stderr.strip():
        print(run.stderr.strip(), file=sys.stderr)
    if changed:
        print('WARNING the working tree changed during the review.',
              file=sys.stderr)
    if run.returncode or result.get('status') != 'SUCCESS' or not response:
        print(f'Review failed, exit {run.returncode}, status '
              f'{result.get("status")}.', file=sys.stderr)
        print(result.get('error') or '', file=sys.stderr)
        return 1
    return 2 if changed else 0


if __name__ == '__main__':
    sys.exit(main())
