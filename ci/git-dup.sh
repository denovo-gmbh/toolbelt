#!/bin/bash
set -e

# Globals
DEPLOY_KEY_FILE="$(pwd)/.id_deploy_key_temp___"
GIT_REMOTE="target-$(cat /dev/random | LC_CTYPE=C tr -dc "[:alnum:]" | head -c 8; echo)"

usage () {
    echo "usage: ./git-dup.sh [-h] [-f] <remote>" >&2
    echo >&2
    echo "Pushes current checkout branch to additional repository using an optional temporary deploy key." >&2
    echo "The deploy key needs to have access rights to the additonal repo." >&2
    echo "" >&2
    echo "The optional temporary deploy key is specified in GIT_DEPLOY_KEY environment variable." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "-h    Show this help" >&2
    echo "-f    Force cleanup" >&2
}

forceClean () {
  echo "🧼  Performing forced cleanup"
  rm -f "$DEPLOY_KEY_FILE"
}

cleanup () {
  if git ls-remote $GIT_REMOTE --quiet 2>/dev/null; then
    echo "🗑   Cleaning up"
    git remote rm $GIT_REMOTE
  fi
  rm "$DEPLOY_KEY_FILE" 2> /dev/null
}

# Error handling / finalize
trap 'cleanup' EXIT

while getopts ":h:f" flag; do
    case "${flag}" in
        h) usage; exit 2;;
        f) forceClean;;
        *) usage; exit 2;;
    esac
done

main () {
  # Checks
  if [ "$#" -lt 1 ]; then
    usage
    exit 2
  fi

  # Preparation
  BRANCH=`git rev-parse --abbrev-ref HEAD`
  
  # Preparation for deploy key
  if [ -f "$DEPLOY_KEY_FILE" ]; then
    echo "✋  Orphaned temporary deploy key file found. Stopping for safety reasons. Perform forced cleanup."
    exit 4
  fi

  if [ "$GIT_DEPLOY_KEY" ]; then
    echo "🔑  Using temporary deploy key";
    echo "$GIT_DEPLOY_KEY" > "$DEPLOY_KEY_FILE"
    chmod 600 "$DEPLOY_KEY_FILE"
    export GIT_SSH_COMMAND="ssh -i '$DEPLOY_KEY_FILE' -o 'IdentitiesOnly yes'"
  fi

  if ! git ls-remote $GIT_REMOTE --quiet 2>/dev/null; then
    # Remote is not set
    echo "🌍  Adding remote '$GIT_REMOTE'"
    git remote add $GIT_REMOTE "${@: -1}"
  fi

  git fetch $GIT_REMOTE

  if ! [[ -z "$(git ls-remote --heads $GIT_REMOTE $BRANCH)" ]]; then
    # Remote branch does exists - merge it
    echo "⬇️   Pulling from existing remote"
    git pull $GIT_REMOTE $BRANCH --no-rebase -s resolve
  fi

  echo "⬆️   Pushing changes"
  git push -u $GIT_REMOTE $BRANCH
}

( cd . && main "$@" )
