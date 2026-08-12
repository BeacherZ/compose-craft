#!/bin/sh
VOLUME_PREFIX="${VOLUME_PREFIX:-/opt/docker/{container_name}}"
sed -i "s#__VOLUME_PREFIX__#${VOLUME_PREFIX}#g" /usr/share/nginx/html/index.html
nginx -g 'daemon off;'
