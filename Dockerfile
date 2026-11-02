FROM alpine:3.20
ARG XRAY_VERSION=v26.10.31
ARG DEFAULT_UUID=8fab8c9a-6b1f-4c0d-8ff1-4b4ab4925869
RUN apk add --no-cache nginx ca-certificates curl unzip \
 && curl -fsSL -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" \
 && mkdir -p /usr/local/share/xray && unzip -q /tmp/xray.zip -d /tmp/xray \
 && install -m 755 /tmp/xray/xray /usr/local/bin/xray \
 && cp /tmp/xray/*.dat /usr/local/share/xray/ \
 && rm -rf /tmp/xray /tmp/xray.zip && apk del unzip
ENV PORT=10000 \
    UUID=${DEFAULT_UUID} \
    WS_PATH=/vpn \
    XRAY_LOCATION_ASSET=/usr/local/share/xray
COPY config.json.template nginx.conf.template /etc/render-vpn/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 10000
ENTRYPOINT ["/entrypoint.sh"]
