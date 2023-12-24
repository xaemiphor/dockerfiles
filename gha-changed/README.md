# gha-changed

This image checks each folder within the target(GITHUB_WORKSPACE by default), and outputs a json array of each folder that had changes since the last push.   
Will automatically limit itself to 256 items per Github limit.   
A folder is considered changed if the last commit to any object within the folder is modified.

## Github/Gitea/Forgejo Actions usage
```
jobs:
  identify:
    outputs:
      changed: "${{ steps.changed.outputs.changed }}"
    steps:
      - name: gha-changed
        id: changed
        uses: docker://ghcr.io/xaemiphor/gha-changed:0.0.1
        env:
          git_root: ${{ github.workspace }}
          glob: *
          ignore: _common
  build:
    needs: identify
    runs-on: ubuntu-latest
    if: ${{ needs.identify.outputs.changed != '[]' && needs.identify.outputs.changed != '' }}
    strategy:
      fail-fast: false
      matrix:
        folder: ${{ fronJSON(needs.identify.outputs.changed) }}
    steps:
      - run: |
          echo "${{ matrix.folder }}"
```
