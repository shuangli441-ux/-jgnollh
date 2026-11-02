#!/bin/sh
set -eu
PORT="${PORT:-10000}"
UUID="${UUID:-8fab8c9a-6b1f-4c0d-8ff1-4b4ab4925869}"
WS_PATH="${WS_PATH:-/vpn}"
mkdir -p /etc/xray
sed -e "s|__UUID__|${UUID}|g" -e "s|__WS_PATH__|${WS_PATH}|g" \
  /etc/render-vpn/config.json.template > /etc/xray/config.json
sed -e "s|__PORT__|${PORT}|g" -e "s|__WS_PATH__|${WS_PATH}|g" \
  /etc/render-vpn/nginx.conf.template > /etc/nginx/render-vpn.conf
echo "render-vpn: PORT=${PORT} WS_PATH=${WS_PATH}"
/usr/local/bin/xray run -c /etc/xray/config.json &
XRAY_PID=$!
sleep 1
kill -0 "$XRAY_PID" || { echo "xray failed to start"; exit 1; }
nginx -c /etc/nginx/render-vpn.conf &
NGINX_PID=$!
trap 'kill $XRAY_PID $NGINX_PID 2>/dev/null; exit 0' TERM INT
# exit (so Render restarts) if either process dies
while kill -0 "$XRAY_PID" 2>/dev/null && kill -0 "$NGINX_PID" 2>/dev/null; do sleep 5; done
echo "a child process exited"; kill $XRAY_PID $NGINX_PID 2>/dev/null || true; exit 1
