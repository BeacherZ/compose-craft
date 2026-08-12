#!/bin/sh
VOLUME_PREFIX="${VOLUME_PREFIX:-/opt/docker/{container_name}}"
sed -i "s|/opt/docker/\{container_name\}|${VOLUME_PREFIX}|g" /usr/share/nginx/html/index.html
nginx -g 'daemon off;'
