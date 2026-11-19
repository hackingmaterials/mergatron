#!/usr/bin/env bash
# mergatron_label.sh runs only the three PR edits the rules call for. "gh" is
# a stub that records its arguments, so this runs offline and edits nothing.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp "$root"/github-template/{mergatron_lib.sh,mergatron_label.sh} "$tmp/"
mkdir "$tmp/bin"
printf '#!/usr/bin/env bash\necho "$*" >"%s/ran"\n' "$tmp" >"$tmp/bin/gh"
chmod +x "$tmp/bin/gh"
export PATH="$tmp/bin:$PATH"
failed=0

# Usage: check "<expected gh arguments, or refused>" <script arguments...>
check() {
  local want="$1"
  shift
  rm -f "$tmp/ran"
  bash "$tmp/mergatron_label.sh" "$@" >/dev/null 2>&1 || true
  local got=refused
  [[ ! -f "$tmp/ran" ]] || got=$(cat "$tmp/ran")
  if [[ "$got" != "$want" ]]; then
    echo "FAIL: mergatron_label.sh $*: got '$got', expected '$want'"
    failed=1
  fi
}

check "pr edit 7 --add-reviewer=someone --add-label review requested" 7 escalate @someone
check "pr edit 7 --add-label not ready to merge" 7 hold
check "pr edit 7 --remove-label not ready to merge" 7 release
check refused 7 escalate
check refused 7 unlabel "do not merge"
check refused --base=x hold
exit $failed
