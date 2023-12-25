#!/bin/bash
set -e
source /bin/_ci.sh

## Args parsing
_args=( '-p' )
_set_config profile production
_set_config offline "true"
_set_array_config glob "**"

## Args building
_args+=( '--profile' "${__profile}" )
if [[ "${__offline}" == "true" ]]; then
	_args+=( '--offline' )
fi

anisble-lint --version
ansible-lint ${_args[@]} "${__glob[@]}"
