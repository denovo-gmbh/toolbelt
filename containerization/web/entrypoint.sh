#!/usr/bin/env sh
set -e

# Check if env.sh is installed
if ! hash env.sh 2>/dev/null
then
  echo "🚨  env.sh was not installed in PATH. See https://github.com/denovo-gmbh/toolbelt/blob/master/containerization/web/README.md for more details."
  exit 1
fi

NGINX_TEMPLATE=${NGINX_TEMPLATE:-/etc/nginx/conf.d/default.conf.template}

if [ -z "$PORT" ]; then
  echo "🚨  Environment variable \$PORT not configured. Falling back to port 80"
  export PORT=80
fi

echo "🌍  Preparing nginx to listen on port $PORT"
envsubst '${PORT}' < "$NGINX_TEMPLATE" > /etc/nginx/conf.d/default.conf

echo "💲  Preparing environment variables"
env.sh

exec "$@"