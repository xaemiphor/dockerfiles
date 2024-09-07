# ansible-lint

## Github/Gitea/Forgejo Actions usage
```
- name: ansible-lint
  uses: docker://ghcr.io/xaemiphor/ansible-lint:0.0.3
  env:
    profile: production
    offline: true
    exclude: |
      path/
      another_path/
    glob: '**'
```
## Drone usage
```
- name: ansible-lint
  image: ghcr.io/xaemiphor/ansible-lint:0.0.3
  settings:
    profile: production
    offline: true
    exclude:
      - path/
      - another_path/
    glob: '**'
```
## Woodpecker usage
```
- name: ansible-lint
  image: ghcr.io/xaemiphor/ansible-lint:0.0.3
  settings:
    profile: production
    offline: true
    exclude:
      - path/
      - another_path/
    glob: '**'
```
