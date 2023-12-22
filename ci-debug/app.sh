#!/bin/bash
set -e
source /bin/_ci.sh
if [[ "${CI:-}" == "woodpecker" ]]; then
  WOODPECKER=true
fi
_header "CI Env check"
echo "CI: ${CI:-}"
echo "Github Actions: ${GITHUB_ACTIONS:-false}"
echo "Gitea Actions: ${GITEA_ACTIONS:-false}"
echo "Drone: ${DRONE:-false}"
echo "Woodpecker: ${WOODPECKER:-false}"
_footer

_header "Variable list"
env | awk -F'=' '/=/{print $1}'
_footer

_header "Test Data 'FOO'"
__VARS=( $(env | awk -F'=' 'tolower($1) ~ /foo/ && /=/{print $1}') )
for entry in ${__VARS[@]}; do
  echo "[variable] ${entry}"
  echo "[value] ${!entry}"
done
_footer
