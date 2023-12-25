#!/bin/bash
set -e
source /bin/_ci.sh

_args=( '-x' )
# Parse inputs
_set_config path "${CI_WORKSPACE:-${DRONE_WORKSPACE:-${GITHUB_WORKSPACE}}}"
_set_config output_file "TODO.md"
_set_config skip_unsupported "true"
_set_array_config glob "**"
_set_array_config ignore

# Rerun self as taret UID to simplify potential permissions issues
_rerun_as_user "$(stat -c "%u" "${__path}")" "$(stat -c "%g" "${__path}")" "${0}"

if [[ "${__skip_unsupported}" == "true" ]]; then
	_args+=( '--skip-unsupported' )
fi

for __entry in ${__ignore[@]}; do
  _args+=( '--ignore' "${__entry}" )
done

cd ${__path}

_header "TODO Outcome"
leasot --reporter table ${_args[@]} "${__glob[@]}"
_footer
if [[ ! -e "${__output_file}" ]]; then
  touch "${__output_file}"
fi
leasot --reporter markdown ${_args[@]} "${__glob[@]}" > "${__output_file}"
