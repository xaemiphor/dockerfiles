# ci-debug

## Github Actions usage
```
- name: ci-debug
  uses docker://
  env:
    foo_string: bar
    foo_array: |
      bar_one
      bar_two
```

## Drone usage
```
- name: ci-debug
  image:
  settings:
    foo_string: bar
    foo_array:
      - bar_one
      - bar_two
```

## Woodpecker usage
```
- name: ci-debug
  image:
  settings:
    foo_string: bar
    foo_array:
      - bar_one
      - bar_two
```
