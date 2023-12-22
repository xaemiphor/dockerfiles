#!/bin/bash
set -e
source /bin/_ci.sh
# Parse inputs
case ${__CI} in
  github-actions|gitea-actions)
    __commit_user=${commit_user:-${GITHUB_ACTOR}}
    __commit_email=${commit_email:-${GITHUB_ACTOR}@users.noreply.${__CI%-*}.com}
    __commit_message=${commit_message:-"ci-auto: automated commit by ${__CI} from ${GITHUB_SHA}"}
    __commit_branch=${commit_branch:-}
    __error_on_commit=${error_on_commit:-true}
    OIFS=$IFS
    IFS=$'\n' __glob=( ${glob:-.} )
    IFS=${OIFS}
    ;;
  drone|woodpecker)
    __commit_user=${PLUGIN_COMMIT_USER:-${CI_COMMIT_AUTHOR:-${DRONE_COMMIT_AUTHOR:-${__CI}}}}
    __commit_email=${PLUGIN_COMMIT_EMAIL:-${CI_COMMIT_AUTHOR_EMAIL:-${DRONE_COMMIT_AUTHOR_EMAIL:-${__CI}@noreply.localhost}}}
    __commit_message=${PLUGIN_COMMIT_MESSAGE:-"ci-auto: automated commit by ${__CI} from ${CI_COMMIT_SHA:-${DRONE_COMMIT_SHA:-????}}"}
    __commit_branch=${PLUGIN_COMMIT_BRANCH:-${CI_COMMIT_BRANCH:-${DRONE_COMMIT_BRANCH:-}}}
    __error_on_commit=${PLUGIN_ERROR_ON_COMMIT:-true}
    IFS=',' read -ra __glob <<< "${PLUGIN_GLOB:-.}"
    ;;
  *)
    _error "Could not identify CI environment"
    exit 1
    ;;
esac

# Minor tweaks from Drone environment
if [[ -n "${CI_WORKSPACE:-${DRONE_WORKSPACE:-}}" ]]; then
  cd ${CI_WORKSPACE:-${DRONE_WORKSPACE:-}}
fi

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
if ! git diff --quiet --exit-code HEAD -- "${__glob[@]}"; then
  git add "${__glob[@]}"
  git commit -m "${__commit_message}" --author="${__commit_user} <${__commit_email}>"
  git push --quiet --set-upstream origin ${__commit_branch}
  if [[ "${__error_on_commit}" == "true" ]]; then
    exit 1
  fi
fi
