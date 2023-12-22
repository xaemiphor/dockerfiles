# ci-debug

## Github/Gitea/Forgejo Actions usage
```
- name: ci-debug
  uses: docker://ghcr.io/xaemiphor/ci-debug:0.0.1
  env:
    foo_string: bar
    foo_array: |
      bar_one
      bar_two
```

## Drone usage
```
- name: ci-debug
  image: ghcr.io/xaemiphor/ci-debug:0.0.1
  settings:
    foo_string: bar
    foo_array:
      - bar_one
      - bar_two
```

## Woodpecker usage
```
- name: ci-debug
  image: ghcr.io/xaemiphor/ci-debug:0.0.1
  settings:
    foo_string: bar
    foo_array:
      - bar_one
      - bar_two
```
