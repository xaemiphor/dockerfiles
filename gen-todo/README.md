# gen-todo

## Github/Gitea/Forgejo Actions usage
```
- name: gen-todo
  uses: docker://ghcr.io/xaemiphor/gen-todo:0.0.1
  env:
#    path: ${{ github.workspace }} # Default
    ignore: |
      .gitignore
    glob: |
      .
      folder/*
```
## Drone usage
```
- name: gen-todo
  image: ghcr.io/xaemiphor/gen-todo:0.0.1
  settings:
    ignore:
      - .gitignore
    glob:
      - .
      - folder/*
```
## Woodpecker usage
```
- name: gen-todo
  image: ghcr.io/xaemiphor/gen-todo:0.0.1
  settings:
    ignore:
      - .gitignore
    glob:
      - .
      - folder/*
```
