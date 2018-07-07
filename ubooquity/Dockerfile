FROM openjdk:8-alpine

# Create 'app' User
ARG PUID=1000
ARG PGID=1000
RUN mkdir -p /opt/app /data /config && \
    addgroup -g ${PGID} app && \
    adduser -h /opt/app -D -g '' -G app -u ${PUID} app && \
    chown -R app:app /opt/app /data /config
USER app
WORKDIR /opt/app

# Fetch and Install Sources
ARG APP_VER="2.1.1"
RUN wget -q -O /tmp/app.zip \
        "http://vaemendis.net/ubooquity/downloads/Ubooquity-${APP_VER}.zip" && \
    unzip /tmp/app.zip -d /opt/app && \
    rm -f /tmp/app.zip

# Final Touches
EXPOSE 2202 2203
VOLUME /config /data
ENTRYPOINT ["java", "-Xmx512m", "-jar", "/opt/app/Ubooquity.jar"]
CMD ["--headless", "--host", "0.0.0.0", "--remoteadmin", "--workdir", "/config"]
