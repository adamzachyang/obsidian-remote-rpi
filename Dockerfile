FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

ARG OBSIDIAN_VERSION=1.5.8
ARG ARCH=arm64

# Update and install extra packages.
RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        libnss3 \
        zlib1g-dev \
        dbus-x11 \
        uuid-runtime && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Download and install Obsidian
RUN echo "**** download obsidian ****" && \
    curl -L -o /obsidian.AppImage \
        "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}-${ARCH}.AppImage" && \
    chmod +x /obsidian.AppImage && \
    /obsidian.AppImage --appimage-extract

# Install required packages
RUN apt update && apt install libfuse2 libatk1.0-0 libatk-bridge2.0-0 libcups2 libgtk-3-0 -y

# Environment variables
ENV CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8443" \
    CUSTOM_USER="" \
    PASSWORD="" \
    SUBFOLDER="" \
    TITLE="Obsidian v$OBSIDIAN_VERSION" \
    FM_HOME="/vaults"

# Add local files
COPY root/ /

# Expose ports and volumes
EXPOSE 8080 27123 27124
VOLUME ["/config","/vaults"]

# Define a healthcheck
HEALTHCHECK CMD curl --fail http://localhost:8080/ || exit 1
