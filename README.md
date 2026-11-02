# render-vpn — VLESS + WebSocket (Xray) for Render

Container layout:
- nginx listens on `0.0.0.0:$PORT` (Render sets `PORT`; default 10000)
  - `GET /`  -> `200 ok` (Render health check)
  - `/vpn`   -> WebSocket upgrade proxied to Xray on 127.0.0.1:10001
- Xray (v26.10.31) VLESS inbound, WS transport, path `/vpn`

Env vars: `PORT` (default 10000), `UUID` (default = UUID.txt), `WS_PATH` (default /vpn).

## Local
    docker build -t render-vpn:local .
    docker run -e PORT=10000 -p 10000:10000 render-vpn:local
    curl http://127.0.0.1:10000/        # -> ok

## Deploy on Render
1. Push this folder to a GitHub/GitLab repo (or push the image to a registry).
2. Render -> New -> Web Service -> pick the repo, Runtime = Docker, Plan = Free
   (or use render.yaml as a Blueprint). Health check path `/`.
3. Recommended: set env `UUID` to a fresh value in the dashboard if the repo/image is public.

## Client settings (v2rayN / v2rayNG / Shadowrocket / Clash Meta / sing-box)
- Protocol: VLESS
- Address: YOUR-SERVICE.onrender.com
- Port: 443
- UUID: (see UUID.txt)
- Encryption: none, Flow: (empty)
- Transport: ws, Path: /vpn, Host: YOUR-SERVICE.onrender.com
- TLS: on, SNI: YOUR-SERVICE.onrender.com, ALPN: http/1.1 (fingerprint chrome optional)

Share link:
    vless://<UUID>@YOUR-SERVICE.onrender.com:443?encryption=none&security=tls&sni=YOUR-SERVICE.onrender.com&type=ws&host=YOUR-SERVICE.onrender.com&path=%2Fvpn#render-vpn

## Caveats
- Render free instances sleep after ~15 min without inbound HTTP traffic; the first
  connection after sleep takes ~30-60 s to wake. Free tier has monthly hour/bandwidth limits.
- TCP only via WebSocket; no UDP.
- Xray logs a deprecation warning for WS transport; it still works.
