#!/bin/bash
set -e
source /bin/_ci.sh
# Parse inputs
_set_config "path" "${CI_WORKSPACE:-${DRONE_WORKSPACE:-${GITHUB_WORKSPACE}}}"
_set_config "error_on_commit" "false"
_set_array_config "glob" "*"

case ${__CI} in
  github-actions|gitea-actions)
    __commit_user=${commit_user:-${GITHUB_ACTOR}}
    __commit_email=${commit_email:-${GITHUB_ACTOR}@users.noreply.${__CI%-*}.com}
    __commit_message=${commit_message:-"ci-auto: automated commit by ${__CI} from ${GITHUB_SHA}"}
    __commit_branch=${commit_branch:-${GITHUB_REF_NAME}}
    ;;
  drone|woodpecker)
    __commit_user=${PLUGIN_COMMIT_USER:-${CI_COMMIT_AUTHOR:-${DRONE_COMMIT_AUTHOR:-${__CI}}}}
    __commit_email=${PLUGIN_COMMIT_EMAIL:-${CI_COMMIT_AUTHOR_EMAIL:-${DRONE_COMMIT_AUTHOR_EMAIL:-${__CI}@noreply.localhost}}}
    __commit_message=${PLUGIN_COMMIT_MESSAGE:-"ci-auto: automated commit by ${__CI} from ${CI_COMMIT_SHA:-${DRONE_COMMIT_SHA:-????}}"}
    __commit_branch=${PLUGIN_COMMIT_BRANCH:-${CI_COMMIT_BRANCH:-${DRONE_COMMIT_BRANCH:-}}}
    ;;
  *)
    _error "Could not identify CI environment"
    exit 1
    ;;
esac

_rerun_as_user "$(stat -c "%u" "${__path}")" "$(stat -c "%g" "${__path}")" "${0}"

cd "${__path}"

## Extra GIT Setup (copied from https://github.com/drone/drone-git/blob/master/posix/clone#L27)
if [[ -n "${CI_NETRC_MACHINE:-${DRONE_NETRC_MACHINE:-}}" ]]; then
  cat <<EOF > ${HOME}/.netrc
machine ${CI_NETRC_MACHINE:-${DRONE_NETRC_MACHINE}}
login ${CI_NETRC_USERNAME:-${DRONE_NETRC_USERNAME}}
password ${CI_NETRC_PASSWORD:-${DRONE_NETRC_PASSWORD}}
EOF
fi

if [[ -n "${CI_SSH_KEY:-${DRONE_SSH_KEY:-}}" ]]; then
  mkdir ${HOME}/.ssh
  echo -n "${CI_SSH_KEY:-${DRONE_SSH_KEY:-}}" > ${HOME}/.ssh/id_rsa
  chmod 600 ${HOME}/.ssh/id_rsa

  touch ${HOME}/.ssh/known_hosts
  chmod 600 ${HOME}/.ssh/known_hosts
  ssh-keyscan -H ${CI_NETRC_MACHINE:-${DRONE_NETRC_MACHINE:-}} > /etc/ssh/ssh_known_hosts 2> /dev/null
fi

# Pull latest, check for differences, commit and push
git config pull.ff only
git pull --quiet origin "${__commit_branch}"
# TODO Add some sort of support for globbing/include/exclude/etc here
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  echo "Additions or modifications noted, committing and pushing to repository."
  if [[ "${__glob[@]}" == "*" ]]; then
    git add . # Adds all, may eventually need to figure out globbing solution as referenced
  else
    for x in ${__glob[@]}; do
      git add ${x}
    done
  fi
  git config user.name "${__commit_user}"
  git config user.email "${__commit_email}"
  git commit -m "${__commit_message}" --author="${__commit_user} <${__commit_email}>"
  git push --quiet --set-upstream origin ${__commit_branch}
  if [[ "${__error_on_commit}" == "true" ]]; then
    exit 1
  fi
fi
