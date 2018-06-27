# BUILD using context = https://github.com/janeczku/calibre-web.git

# Image built without GDrive support to save space
# (expected that users will use docker volumes for deployment instead)

FROM python:alpine

# Get Depenencies
RUN apk --no-cache add \
        git \
        imagemagick \
        imagemagick-dev \
    && \
    pip --no-cache-dir install -U \
        "Babel>=1.3" \
        "Flask-Babel>=0.11.1" \
        "Flask-Login>=0.3.2" \
        "Flask-Principal>=0.3.2" \
        "singledispatch>=3.4.0.0" \
        "backports_abc>=0.4" \
        "Flask>=0.11" \
        "iso-639>=0.4.5" \
        "PyPDF2==1.26.0" \
        "pytz>=2016.10" \
        "requests>=2.11.1" \
        "SQLAlchemy>=0.8.4" \
        "tornado>=4.1" \
        "Wand>=0.4.4" \
        "unidecode>=0.04.19" \
    && exit 0

# Make Application User and Directory Structure
ARG PUID=1000
ARG PGID=1000
RUN addgroup -g ${PGID} app && \
    adduser -D -g '' -G app -u ${PUID} app && \
    mkdir -p /opt/app/vendor /books && \
    chown app:app /opt/app /opt/app/vendor /books
USER app

# Install KindleGen
# https://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000765211
# Read EULA from the tarball linked below
ARG KINDLEGEN_URL="http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz"
RUN wget -q -O - "${KINDLEGEN_URL}" | \
        tar -xzf - -C /opt/app/vendor kindlegen && \
    chmod 0755 /opt/app/vendor/kindlegen

# Copy Application Files
ARG APP_REPO="https://github.com/janeczku/calibre-web.git"
ARG APP_COMMIT="a06748e"
RUN git clone --depth 1 --quiet "${APP_REPO}" /tmp/app && \
    cd /tmp/app && \
    git checkout ${APP_COMMIT} . && \
    cp cps.py babel.cfg messages.pot /opt/app && \
    cp -R cps /opt/app/ && \
    rm -rf /tmp/app

# Final Touches
VOLUME ["/books"]
EXPOSE 8083
CMD ["python", "/opt/app/cps.py", "-p", "/books/calibre-web.db"]
