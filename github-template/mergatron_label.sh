#!/usr/bin/env bash
# The triage bot's only way to edit a PR: the label and reviewer changes the rules call for.
#
#   .github/mergatron_label.sh <PR number> escalate <maintainer login>
#   .github/mergatron_label.sh <PR number> hold      (adds "not ready to merge")
#   .github/mergatron_label.sh <PR number> release   (removes it)
set -euo pipefail

here="$(dirname "$0")"
source "$here/mergatron_lib.sh"

usage="usage: mergatron_label.sh <PR number> escalate <login> | hold | release"
pr="${1:?$usage}"
verb="${2:?$usage}"
[[ "$pr" =~ ^[0-9]+$ ]] || fail "'$pr' is not a PR number"
who="#$pr"

case "$verb" in
  escalate)
    login="${3:?$usage}"
    gh pr edit "$pr" --add-reviewer="${login#@}" --add-label "review requested"
    ;;
  hold) gh pr edit "$pr" --add-label "not ready to merge" ;;
  release) gh pr edit "$pr" --remove-label "not ready to merge" ;;
  *) fail "$usage" ;;
esac
