#!/bin/bash

# Globals
HL='\033[0;34m\033[1m' # Highlight
NC='\033[0m' # No Color
OUTPUT_INI=
OUTPUT_JSON=
VERSION=`git describe --tags --abbrev=0 2> /dev/null | sed -e 's/-[0-9]*//g' | sed 's/[^0-9.]*//g'`
export VERSION=${VERSION:-0.0.0}
AHEAD=`git rev-list "$VERSION"..HEAD --count 2> /dev/null`
export AHEAD=${AHEAD:-"no version found"}
export COMMIT=`git log --pretty="%H" -n1 HEAD`
BRANCH=`git branch | grep \* | cut -d ' ' -f2`
export BRANCH=${BRANCH:-unknown}

# Help
usage () {
    echo "usage: source ./gen-stats.sh [-h] [-i] [-j] <FILENAME>" >&2
    echo >&2
    echo "Generate build_stats.* file as JSON or INI. When sourcing bash variables \$VERSION, \$AHEAD, \$COMMIT and \$BRANCH will be exported." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "-h    Show this help" >&2
    echo "-i    Write as .ini file" >&2
    echo "-j    Write as .json file" >&2
}

while getopts "hij" flag; do
    case "${flag}" in
        h) usage; exit 0;;
        i) OUTPUT_INI=yes;;
        j) OUTPUT_JSON=yes;;
        *) usage; exit 0;;
    esac
done

main () {
  # Checks
  if [ "$#" -lt 1 ]; then
    usage
    exit 0
  fi

  echo "👷‍♂️  Generating build stats"
  echo ""
  echo -e "Current version:                  $HL$VERSION$NC"
  echo -e "Commit is ahead of version tag:   $HL$AHEAD$NC"
  echo -e "Hash of commit:                   $HL$COMMIT$NC"
  echo -e "Build originates from branch:     $HL$BRANCH$NC"
  echo ""

  if [ "$OUTPUT_INI" ]; then
    FILENAME="${@: -1}.ini"
    echo "📝  Writing <$FILENAME> as INI"
    echo "[version]" > $FILENAME
    echo "VERSION_TAG = $VERSION" >> $FILENAME
    echo "VERSION_AHEAD = $AHEAD" >> $FILENAME
    echo "VERSION_COMMIT = $COMMIT" >> $FILENAME
    echo "VERSION_BRANCH = $BRANCH" >> $FILENAME
  fi

  if [ "$OUTPUT_JSON" ]; then
    FILENAME="${@: -1}.json"
    echo "📝  Writing <$FILENAME> as JSON"
    echo "{\"version\":\"$VERSION\",\"ahead\":\"$AHEAD\",\"branch\":\"$BRANCH\",\"commit\":\"$COMMIT\"}" > $FILENAME
  fi
}

( cd . && main "$@" )
