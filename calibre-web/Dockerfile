# Image built without GDrive support to save space
# (expected that users will use docker volumes for deployment instead)
FROM python:alpine

# Make Application User and Directory Structure
ARG PUID=1000
ARG PGID=1000
WORKDIR /opt/app
RUN addgroup -g ${PGID} app && \
    adduser -D -g '' -G app -u ${PUID} app && \
    mkdir -p /opt/app/vendor /books && \
    chown app:app /opt/app /opt/app/vendor /books

# Get Depenencies
COPY --chown=app:app src/requirements.txt ./requirements.txt
RUN apk --no-cache add \
        imagemagick \
        imagemagick-dev \
    && \
    pip --no-cache-dir install -U -r requirements.txt

USER app

# Install KindleGen
# https://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000765211
# Read EULA from the tarball linked below
ARG KINDLEGEN_URL="http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz"
RUN wget -q -O - "${KINDLEGEN_URL}" | \
        tar -xzf - -C /opt/app/vendor kindlegen && \
    chmod 0755 /opt/app/vendor/kindlegen

# Copy Application Files
COPY --chown=app:app src/cps.py src/babel.cfg src/messages.pot ./
COPY --chown=app:app src/cps/ ./cps/

# Final Touches
VOLUME ["/books"]
EXPOSE 8083
CMD ["python", "/opt/app/cps.py", "-p", "/books/calibre-web.db"]
