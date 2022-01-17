#!/bin/bash
set -e

# Globals
HL='\033[0;34m\033[1m' # Highlight
ER='\033[0;31m'
NC='\033[0m' # No Color
HEROKU_API_KEY=
HEROKU_APP_NAME=
HEROKU_DYNO=web
DOCKER_IMAGE=

# Help
usage () {
    echo "usage: ./heroku-deploy.sh -k <HEROKU_API_KEY> -a <HEROKU_APP_NAME> -i <DOCKER_IMAGE>" >&2
    echo >&2
    echo "Deploy a docker image to Heroku." >&2
}

while getopts "hk:a:i:t:d:" flag; do
    case "${flag}" in
        h) usage; exit 0;;
        k) HEROKU_API_KEY=$OPTARG;;
        a) echo -e "🌍   Using Heroku app $HL${OPTARG}$NC" && HEROKU_APP_NAME=$OPTARG;;
        i) echo -e "🐳   Using Docker image $HL${OPTARG}$NC" && DOCKER_IMAGE=$OPTARG;;
        d) echo -e "🚀   Using $HL${OPTARG}$NC dyno" && HEROKU_DYNO=$OPTARG;;
        *) usage; exit 0;;
    esac
done

main () {
  # Checks
  if [ -z $HEROKU_API_KEY ]; then echo -e "🛑   ${ER}Heroku API key${NC} is missing"; exit 1; fi
  if [ -z $HEROKU_APP_NAME ]; then echo -e "🛑   ${ER}Heroku App name${NC} is not specified"; exit 1; fi
  if [ -z $DOCKER_IMAGE ]; then echo -e "🛑   No ${ER}Docker image${NC} specified"; exit 1; fi

  # Parse version number
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/denovo-gmbh/toolbelt/master/ci/gen-stats.sh)" -- -i -s build_stats
  source build_stats.sh

  docker login --username=_ --password=$HEROKU_API_KEY registry.heroku.com
  docker pull $DOCKER_IMAGE:$DOCKER_TAG
  docker tag $DOCKER_IMAGE:$DOCKER_TAG registry.heroku.com/$HEROKU_APP_NAME/$HEROKU_DYNO
  docker push registry.heroku.com/$HEROKU_APP_NAME/$HEROKU_DYNO
  heroku container:release -a $HEROKU_APP_NAME $HEROKU_DYNO
}

( cd . && main "$@" )
