#!/bin/bash

# Globals
HL='\033[0;34m\033[1m' # Highlight
NC='\033[0m' # No Color
HEROKU_APP=${@: -1}
HEROKU_DYNO=web
DOCKER_FILE=Dockerfile

# Help
usage () {
    echo "usage: ./docker-heroku.sh <HEROKU_APP_NAME>" >&2
    echo >&2
    echo "Generate a docker image and upload it to a Heroku Dyno." >&2
}

while getopts "hf:d:" flag; do
    case "${flag}" in
        h) usage; exit 0;;
        f) echo -e "🗃   Using dockerfile $HL${OPTARG}$NC" && DOCKER_FILE=$OPTARG;;
        d) echo -e "🌍   Using Heroku Dyno $HL${OPTARG}$NC" && HEROKU_DYNO=$OPTARG;;
        *) usage; exit 0;;
    esac
done

main () {
  # Checks
  if [ "$#" -lt 1 ]; then
    usage
    exit 1
  fi

  echo ""
  echo -e "Heroku App:                       $HL$HEROKU_APP$NC"
  echo -e "Heroku Dyno:                      $HL${HEROKU_DYNO:-web}$NC"
  echo ""

  echo "🐳  Starting Docker build"
  docker build -f $DOCKER_FILE -t registry.heroku.com/$HEROKU_APP/${HEROKU_DYNO:-web} .
  docker push registry.heroku.com/$HEROKU_APP/${HEROKU_DYNO:-web}

  if [ ! $(which heroku) ] ; then
    echo "🛑  Heroku CLI not installed. Skipping container release!"  
  else
    echo -e "🌍  Releaseing container $HL${HEROKU_DYNO:-web}$NC on Heroku"
    heroku container:release ${HEROKU_DYNO:-web} --app $HEROKU_APP
  fi
}

( cd . && main "$@" )