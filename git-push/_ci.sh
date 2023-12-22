#!/bin/bash
#VERSION=0.0.4
function _ci {
  if [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
    if [[ "${GITEA_ACTIONS:-false}" == "true" ]]; then
      echo "gitea-actions"
    else
      echo "github-actions"
    fi
  elif [[ "${DRONE:-false}" == "true" ]]; then
    echo "drone"
  elif [[ "${CI:-false}" == "woodpecker" ]]; then
    echo "woodpecker"
  else
    echo "unknown"
  fi
}

__CI=$(_ci)

function _error {
  if [[ "${__CI}" == "github-actions" ]]; then
    echo "::error::[ERROR] $@"
  else
    echo "[ERROR] $@"
  fi
}

set -e
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

function _set_config {
  __var="${1}"
  __default="${2}"
  case ${__CI} in
    github-actions|gitea-actions)
      declare -g __${__var}="${!__var:-${__default}}"
      ;;
    drone|woodpecker)
      __ci_var=PLUGIN_${__var^^}
      declare -g __${__var}="${!__ci_var:-${__default}}"
      ;;
  esac
}

# TODO Add multiline/array config reader

function _rerun_as_user {
  T_UID=${1}
  T_GID=${2}
  if [[ "${T_UID}" != "${EUID}" ]]; then
    addgroup -g ${T_GID} abcabc
    adduser -HD -u ${T_UID} -G abcabc abcabc
    su -mp abcabc -c "${3}"
    exit $?
  fi
}
