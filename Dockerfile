FROM scratch AS licenses
COPY LICENSE LICENSE
COPY NOTICE NOTICE

FROM jlesage/baseimage-gui:ubuntu-22.04-v4.10

LABEL org.opencontainers.image.title="SignalWeb" \
      org.opencontainers.image.description="Provides a Web UI for Signal" \
      org.opencontainers.image.ref.name="main" \
      org.opencontainers.image.licenses='MIT' \
      org.opencontainers.image.vendor="Timo Reymann <mail@timo-reymann.de>" \
      org.opencontainers.image.authors="Timo Reymann <mail@timo-reymann.de>" \
      org.opencontainers.image.url="https://github.com/timo-reymann/SignalWeb" \
      org.opencontainers.image.documentation="https://github.com/timo-reymann/SignalWeb" \
      org.opencontainers.image.source="https://github.com/timo-reymann/SignalWeb.git"

COPY --from=licenses / /

# renovate: datasource=github-releases depName=signalapp/Signal-Desktop
ARG signal_version="v8.2.1"
RUN add-pkg gnupg2 wget ca-certificates libglib2.0-0  \
    && wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg \
    && cat signal-desktop-keyring.gpg | tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null \
    && echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | tee /etc/apt/sources.list.d/signal-xenial.list \
    && add-pkg signal-desktop=`echo ${signal_version} | tail -c+2` \
    && del-pkg gnupg2 wget \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN <<EOT
cat <<EOF > /startapp.sh
#!/bin/sh
exec /usr/bin/signal-desktop --no-sandbox
EOF

set-cont-env APP_NAME "Signal Messenger"
install_app_icon.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Signal-Logo.svg/1200px-Signal-Logo.svg.png"
chmod +x /startapp.sh
rm -rf /var/lib/{apt,dpkg,cache,log}/
EOT

COPY --chown=1000:1000 /rootfs-override /
RUN mkdir -p /run/dbus \
    && chown 1000:1000 /run/dbus

ENV DARK_MODE=1 \
    KEEP_APP_RUNNING=1 \
    DOCKER_IMAGE_PLATFORM=amd64 \
    DOCKER_IMAGE_VERSION=${signal_version} \
    VNC_LISTENING_PORT=-1 \
    WEB_AUDIO=1 \
    WEB_NOTIFICATION=1 \
    SECURE_CONNECTION=1
