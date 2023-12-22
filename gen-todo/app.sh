#!/bin/bash
set -e
source /bin/_ci.sh

_args=( '-x' )
# Parse inputs
_set_config output_file "TODO.md"
_set_config skip_unsupported "true"
case ${__CI} in
  github-actions|gitea-actions)
    OIFS=$IFS
    IFS=$'\n' __glob=( ${glob:-**} )
    IFS=${OIFS}
    ;;
  drone|woodpecker)
    IFS=',' read -ra __glob <<< "${PLUGIN_GLOB:-**}"
    ;;
  *)
    _error "Could not identify CI environment"
    exit 1
    ;;
esac

if [[ "${__skip_unsupported}" == "true" ]]; then
	_args+=( '--skip-unsupported' )
fi

# Minor tweaks from Drone environment
if [[ -n "${CI_WORKSPACE:-${DRONE_WORKSPACE:-}}" ]]; then
  cd ${CI_WORKSPACE:-${DRONE_WORKSPACE:-}}
fi

_header "leasot table"
leasot --reporter table ${_args[@]} "${_glob[@]}"
footer
leasot --reporter markdown ${_args[@]} "${_glob[@]}" > "${__output_file}"
