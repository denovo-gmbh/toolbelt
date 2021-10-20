#!/bin/bash

# Globals
HL='\033[0;34m\033[1m' # Highlight
NC='\033[0m' # No Color
REPOSITORY=${@: -1}
DOCKER_FILE=Dockerfile

# Help
usage () {
    echo "usage: ./docker-build.sh <REPOSITORY>" >&2
    echo >&2
    echo "Generate a docker image and upload it to specified repository." >&2
}

while getopts "hf:" flag; do
    case "${flag}" in
        h) usage; exit 0;;
        f) echo -e "🗃   Using dockerfile $HL${OPTARG}$NC" && DOCKER_FILE=$OPTARG;;
        *) usage; exit 0;;
    esac
done

main () {
  # Checks
  if [ "$#" -lt 1 ]; then
    usage
    exit 1
  fi

  echo "🐳  Starting Docker build"
  git fetch
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/denovo-gmbh/toolbelt/master/ci/gen-stats.sh)" -- -i -s build_stats
  source build_stats.sh

  echo ""
  echo -e "Repository:                       $HL$REPOSITORY$NC"

  docker build -f $DOCKER_FILE -t $REPOSITORY:$VERSION .

}

( cd . && main "$@" )
