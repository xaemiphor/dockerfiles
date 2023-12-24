#!/bin/bash
set -e
source /bin/_ci.sh

_args=( '-x' )
# Parse inputs
_set_config output_file "TODO.md"
_set_config skip_unsupported "true"
_set_array_config glob "*"
_set_array_config ignore

if [[ "${__skip_unsupported}" == "true" ]]; then
	_args+=( '--skip-unsupported' )
fi

# TODO Make root path configurable
if [[ -n "${CI_WORKSPACE:-${DRONE_WORKSPACE:-}}" ]]; then
  cd ${CI_WORKSPACE:-${DRONE_WORKSPACE:-}}
fi

_header "TODO Outcome"
leasot --reporter table ${_args[@]} "${__glob[@]}"
_footer
if [[ ! -e "${__output_file}" ]]; then
  touch "${__output_file}"
fi
for __entry in ${__glob[@]}; do
  _args+=( '--ignore' "${__entry}" )
done
leasot --reporter markdown ${_args[@]} "${__glob[@]}" > "${__output_file}"
