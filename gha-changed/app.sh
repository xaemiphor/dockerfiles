#!/bin/bash
VERSION=1
set -e
changed_root=${changed_root:-${GITHUB_WORKSPACE}}

# Functions
function _error {
  if [[ "${__CI}" == "github-actions" ]]; then
    echo "::error::[ERROR] $@"
  else
    echo "[ERROR] $@"
  fi
}

function _header {
  if [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
    echo "::group::${@}"
  else
    echo "== ${@}"
  fi
}
function _footer {
  if [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
    echo "::endgroup::"
  else
    echo "=="
  fi
}

# Logic
if [[ "$(stat -c "%u" "${changed_root}")" != "${EUID}" ]]; then
  # Switch to user that matches ownership of the git repository
  TARGET_UID=$(stat -c "%u" "${changed_root}")
  TARGET_GID=$(stat -c "%g" "${changed_root}")
  addgroup -g ${TARGET_GID} abc
  adduser -HD -u ${TARGET_UID} -G abc abc
  su -mp abc -c $0
  exit $?
fi
cd $changed_root
if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1 ; then
  # Folder has a git history
  if [[ -n "${SHA_START}" && -n "${SHA_END}" ]] && git merge-base --is-ancestor ${SHA_START} ${SHA_END}; then
    CHANGES=$(git log --name-status --pretty='format:' ${SHA_START}..${SHA_END} | awk -F '[\t/]' '!/^D/&&!/^$/&& $2 !~ /^.github$/{print $2}' | sort -u | jq -c --raw-input -s '[split("\n")[]|select(length>0)][:256]')
  else
    _error "Either one of [${SHA_START}..${SHA_END}] was empty, or ${SHA_START} is not an ancestor of ${SHA_END}. I have not thought through either usecase yet."
    exit 1
  fi
else
  # Folder is not a git repository
  _error "Folder [${changed_root}] did not have a git history."
  exit 1
fi
if [[ "${CHANGES}" != "" && "${CHANGES}" != "null" && "${CHANGES}" != "[]" ]]; then
  _header "Changes detected"
  echo "changed=${CHANGES}" | tee -a "${GITHUB_OUTPUT}"
  _footer
fi
