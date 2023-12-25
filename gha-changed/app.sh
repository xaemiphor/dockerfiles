#!/bin/bash
set -e
source /bin/_ci.sh

_set_config "path" "${CI_WORKSPACE:-${DRONE_WORKSPACE:-${GITHUB_WORKSPACE}}}"
_set_array_config "glob" "*"
_set_array_config "ignore"
# TODO Would include/exclude be more appropriate than glob/ignore?

# Logic
_rerun_as_user "$(stat -c "%u" "${__path}")" "$(stat -c "%g" "${__path}")" "${0}"
cd $__path
if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1 ; then
  # Folder has a git history
  if [[ -n "${SHA_START}" && -n "${SHA_END}" ]] && git merge-base --is-ancestor ${SHA_START} ${SHA_END}; then
    # TODO Figure out how to apply glob/ignore here
    CHANGES=$(git log --name-status --pretty='format:' ${SHA_START}..${SHA_END} | awk -F '[\t/]' '!/^D/&&!/^$/&&/\//&&$2 !~ /^.github$/{print $2}' | sort -u | jq -c --raw-input -s '[split("\n")[]|select(length>0)][:256]')
  else
    _error "Either one of [${SHA_START}..${SHA_END}] was empty, or ${SHA_START} is not an ancestor of ${SHA_END}. I have not thought through either usecase yet."
    exit 1
  fi
else
  # Folder is not a git repository
  _error "Folder [${__path}] did not have a git history."
  exit 1
fi
if [[ "${CHANGES}" != "" && "${CHANGES}" != "null" && "${CHANGES}" != "[]" ]]; then
  _header "Changes detected"
  echo "changed=${CHANGES}" | tee -a "${GITHUB_OUTPUT}"
  _footer
fi
