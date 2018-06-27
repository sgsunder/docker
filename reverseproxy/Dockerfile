FROM nginx:alpine

# Set Up the s6 overlay
ARG S6_VER="v1.21.4.0"
RUN url="https://github.com/just-containers/s6-overlay/releases/download/" && \
    url=${url}${S6_VER} && \
    url=${url}"/s6-overlay-amd64.tar.gz" && \
    wget -O - ${url} | tar xzf - -C /
ENTRYPOINT ["/init"]

# Copy files over
COPY ./etc/ /etc

EXPOSE 80
