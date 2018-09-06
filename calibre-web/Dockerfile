FROM scratch as approot

COPY src/cps.py src/babel.cfg src/messages.pot /
COPY src/cps/ /cps/


FROM python:alpine
LABEL maintainer "Shyam Sunder <sgsunder1@gmail.com>"
WORKDIR /opt/app
  # Image built without GDrive support to save space
  # (expected that users will use docker volumes for deployment instead)

# Make Application User, Directory Structure, Get System Depenencies
ARG PUID=1000
ARG PGID=1000
RUN addgroup -g ${PGID} app \
 && adduser -D -g '' -G app -u ${PUID} app \
 && mkdir -p \
        /opt/app/vendor \
        /books \
 && chown app:app \
        /opt/app \
        /opt/app/vendor \
        /books \
 && apk --no-cache add \
        imagemagick \
        imagemagick-dev \
 && exit 0

# Get App Depenencies
COPY --chown=app:app src/requirements.txt ./requirements.txt
RUN pip --no-cache-dir install -U -r requirements.txt \
 && apk --no-cache add imagemagick

USER app

# Install KindleGen
# https://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000765211
# Read EULA from the tarball linked below
ARG KINDLEGEN_URL="http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz"
RUN wget -q -O - "${KINDLEGEN_URL}" | tar -xzf - -C /opt/app/vendor kindlegen \
 && chmod 0755 /opt/app/vendor/kindlegen

# Copy Application Files
COPY --chown=app:app --from=approot / ./

# Final Touches
VOLUME ["/books"]
EXPOSE 8083
CMD ["python", "/opt/app/cps.py", "-p", "/books/calibre-web.db"]
