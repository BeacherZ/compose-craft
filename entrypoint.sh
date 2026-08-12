#!/bin/sh
VOLUME_PREFIX="${VOLUME_PREFIX:-/opt/docker/{container_name}}"
echo "window.VOLUME_PREFIX = '${VOLUME_PREFIX}';" > /usr/share/nginx/html/config.js
nginx -g 'daemon off;'
