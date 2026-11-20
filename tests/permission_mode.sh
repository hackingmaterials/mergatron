#!/usr/bin/env bash
# Every Claude step must deny tools its allow list leaves out.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
status=0
for wf in github-template/workflows/*.yml .github/workflows/*.yml; do
  steps=$(grep -c 'anthropics/claude-code-action' "$wf" || true)
  pinned=$(grep -cE "^ +--permission-mode default$" "$wf" || true)
  if [[ "$pinned" != "$steps" ]]; then
    echo "$wf: $steps Claude steps, $pinned with --permission-mode default"
    status=1
  fi
done
exit $status
