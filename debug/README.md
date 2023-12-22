# git-push

## Github Actions usage
```
- name: debug
  uses docker://
  env:
    foo_string: bar
    foo_array: |
      bar_one
      bar_two
```

## Drone usage
```
- name: debug
  image:
  settings:
    foo_string: bar
    foo_array:
      - bar_one
      - bar_two
```

## Woodpecker usage
```
- name: debug
  image:
  settings:
    foo_string: bar
    foo_array:
      - bar_one
      - bar_two
```
