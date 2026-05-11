#!/bin/sh
# Generate /_app-config.js from environment variables before nginx starts.
#
# The SPA's `00.runtime-config.client.ts` plugin reads
# `window.__APP_CONFIG__` and patches Nuxt's runtimeConfig.public so
# api / auth / realtime base URLs can change per deployment without a
# rebuild.
#
# Required env vars:
#   APP_API_BASE_URL    — e.g. http://coriolis.example.com/api/v1
#   APP_AUTH_BASE_URL   — e.g. http://coriolis.example.com
#
# Optional env vars:
#   APP_REALTIME_WS_URL — e.g. wss://coriolis.example.com/centrifugo/connection/websocket
#                         If unset, the SPA falls back to the build-time default
#                         (ws://localhost:8000/connection/websocket). Production
#                         deployments MUST set this; the nginx proxy's
#                         /centrifugo/ upstream entry is a prerequisite.
#
# The first two are required. We don't fall back silently because shipping
# the SPA with the build-time placeholder would break every API call.

set -eu

: "${APP_API_BASE_URL:?APP_API_BASE_URL is required}"
: "${APP_AUTH_BASE_URL:?APP_AUTH_BASE_URL is required}"

# Build optional realtimeWsUrl entry. We only emit the field when the env
# var is set so that omitting it in dev is a valid no-op (the plugin
# defaults to ws://localhost:8000/connection/websocket).
REALTIME_LINE=""
if [ -n "${APP_REALTIME_WS_URL:-}" ]; then
  REALTIME_LINE="  realtimeWsUrl: \"${APP_REALTIME_WS_URL}\","
fi

cat > /usr/share/nginx/html/_app-config.js <<EOF
window.__APP_CONFIG__ = {
  apiBaseUrl: "${APP_API_BASE_URL}",
  authBaseUrl: "${APP_AUTH_BASE_URL}",
${REALTIME_LINE}
};
EOF

exec "$@"
