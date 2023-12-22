# git-push

## Github/Gitea/Forgejo Actions usage
```
- name: git-push
  uses docker://ghcr.io/xaemiphor/git-push:0.0.1
  env:
    commit_user: github-actions
    commit_email: github-actions@users.noreply.github.com
    commit_message: "ci: commit from GHA"
    commit_branch: main
    error_on_commit: true
    commit_glob: |
      .
      folder/*
```
## Drone usage
```
- name: git-push
  image: ghcr.io/xaemiphor/git-push:0.0.1
  settings:
    commit_user: droneio
    commit_email: droneio@noreply.localhost
    commit_message: "ci: commit from Drone.io"
    commit_branch: main
    error_on_commit: true
    commit_glob:
      - .
      - folder/*
```
## Woodpecker usage
```
- name: git-push
  image: ghcr.io/xaemiphor/git-push:0.0.1
  settings:
    commit_user: woodpecker
    commit_email: woodpecker@noreply.localhost
    commit_message: "ci: commit from Woodpecker-ci"
    commit_branch: main
    error_on_commit: true
    commit_glob:
      - .
      - folder/*
```
