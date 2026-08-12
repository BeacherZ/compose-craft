#!/bin/sh
VOLUME_PREFIX="${VOLUME_PREFIX:-/opt/docker/{container_name}}"
cat > /usr/share/nginx/html/config.js << EOF
window.VOLUME_PREFIX = '${VOLUME_PREFIX}';
EOF
nginx -g 'daemon off;'
