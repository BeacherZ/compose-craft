#!/bin/sh
if [ -z "$VOLUME_PREFIX" ]; then
    VOLUME_PREFIX='/opt/docker/{container_name}'
fi
printf 'window.VOLUME_PREFIX = "%s";\n' "$VOLUME_PREFIX" > /usr/share/nginx/html/config.js
nginx -g 'daemon off;'
