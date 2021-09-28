# CI/CD tools

`*.sh` scripts can be used by directly downloading it during runtime by calling:

i.e. for `git-dup.sh`:

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/denovo-gmbh/toolbelt/master/ci/git-dup.sh)" -- <GIT_REPO_URI>`

## GIT

 * `git-dup.sh` is used for duplicating source code on multiple remotes