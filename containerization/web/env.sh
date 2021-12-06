#!/bin/sh

# Globals
HL='\033[0;34m\033[1m' # Highlight
ER='\033[0;31m'
NC='\033[0m' # No Color

ENV_JS=./env.js
ENV_PREFIX=REACT_APP_
JS_TARGET="window.env"

# Help
usage () {
    echo "usage: ./env.sh -o <OUTPUT_FILE> -p <PREFIX> -t <JAVASCRIPT_VARIABLE>" >&2
    echo >&2
    echo "Read all environment variables and write variables with prefix to output file in JS notation (env.js)." >&2
}

while getopts "ho:p:t:" flag; do
    case "${flag}" in
        h) usage; exit 0;;
        o) echo "📁   Setting output file to $HL${OPTARG}$NC" && ENV_JS=$OPTARG;;
        p) echo "🎬   Only using variables prefixed with $HL${OPTARG}$NC" && ENV_PREFIX=$OPTARG;;
        t) echo "🎯   Assigning variables to $HL${OPTARG}$NC" && JS_TARGET=$OPTARG;;
        *) usage; exit 0;;
    esac
done

# Recreate environment file
rm -rf $ENV_JS
touch $ENV_JS

# Add assignment 
echo "$JS_TARGET = {" >> $ENV_JS

# Read each line in environment
# Each line represents key=value pairs
printenv | grep "$ENV_PREFIX" | while read line || [[ -n "$line" ]]; do
  # Split env variables by character `=`
  if printf '%s\n' "$line" | grep -q -e '='; then
    varname=$(printf '%s\n' "$line" | sed -e 's/=.*//')
    varvalue=$(printf '%s\n' "$line" | sed -e 's/^[^=]*=//')
  fi
  
  # Append configuration property to JS file
  echo "  $varname: \"$varvalue\"," >> $ENV_JS
done

echo "};" >> $ENV_JS
