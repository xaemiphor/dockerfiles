#!/bin/bash
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
if [[ "${CI:-}" == "woodpecker" ]]; then
	WOODPECKER=true
fi
_header "CI Env check"
echo "Github Actions: ${GITHUB_ACTIONS:-false}"
echo "Drone: ${DRONE:-false}"
echo "Woodpecker: ${WOODPECKER:-false}"
_footer

_header "Variable list"
env | awk -F'=' '{print $1}'
_footer

_header "Test Data 'FOO'"
env | awk -F'=' 'tolower($1) ~ /foo/'
_footer
