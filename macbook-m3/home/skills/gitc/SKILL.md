---
name: gitc
description: Create a git commit. Use when user asks to commit or save progress.
disable-model-invocation: true
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*), Bash(git push:*)
---

## Context
- Status: !`git status`
- Staged diff: !`git diff --staged`
- Recent commits: !`git log --oneline -5`

## Commit message format
Use conventional commit

## Steps
1. Review what's staged and what's not
2. If nothing staged, propose what to stage based on status
3. Write message following the format above
4. Commit, do not push
