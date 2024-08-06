FROM jlesage/baseimage-gui:ubuntu-22.04-v4
# renovate: datasource=github-releases depName=signalapp/Signal-Desktop
ARG signal_version="v7.19.0"
RUN add-pkg gnupg2 wget ca-certificates  \
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
EOT
RUN set-cont-env APP_NAME "Signal Messenger" \
    && install_app_icon.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Signal-Logo.svg/1200px-Signal-Logo.svg.png" \
    && chmod +x /startapp.sh

ENV DARK_MODE=1
ENV KEEP_APP_RUNNING=1
ENV DOCKER_IMAGE_PLATFORM=amd64
ENV DOCKER_IMAGE_VERSION=${signal_version}
ENV VNC_LISTENING_PORT=-1