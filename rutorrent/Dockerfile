FROM php:7-fpm-alpine

# Install s6 overlay
ARG OVERLAY_VERSION="v1.21.4.0"
ARG OVERLAY_ARCH="amd64"
RUN wget -q -O - \
        "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
        | tar -xz -f - -C /
ENTRYPOINT ["/init"]

# Install Application Requirements
ARG PUID=1000
ARG PGID=1000
RUN echo "Using UID ${PUID} and GID ${PGID}" \
    # Create Users
 && addgroup -g ${PGID} app \
 && adduser -D -g '' -G app -u ${PUID} app \
    # Install Runtime Packages
 && apk --no-cache add \
        rtorrent \
        # runtime tools
        rsync \
        screen \
        # plugin tools
        ffmpeg \
        geoip \
        mediainfo \
        sox \
        unrar \
    # Create Log Files
 && ln -sf /dev/stdout /var/log/rutorrent.log \
 && ln -sf /dev/stdout /var/log/rtorrent.log \
 && chown app:app \
        /var/log/rutorrent.log \
        /var/log/rtorrent.log

# Install ruTorrent
COPY --chown=app:app src/ /var/www/rutorrent/

# Patch Files
RUN sed -i.old \
        -e 's#($this->port == 80 ? \"\" : \":\"\.$this->port)#\":\"\.$this->port#' \
        -e 's#\.($this->port == 443 ? \"\" : \":\"\.$this->port)##' \
        /var/www/rutorrent/php/Snoopy.class.inc

# Add Runtime Files
COPY root/ /

# Final Touches
EXPOSE 3000 5000 51413 6881/udp
VOLUME /config /downloads
