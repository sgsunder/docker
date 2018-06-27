FROM alpine:latest

RUN apk --no-cache add \
        openvpn \
        iptables \
        sudo \
    && \
    wget -O /temp.zip \
         "https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip" && \
    mkdir -p /pia && \
    unzip /temp.zip -d /pia && \
    rm -f /temp.zip && \
    addgroup -S vpn && \
    echo "root ALL=(ALL:ALL) ALL" > /etc/sudoers

COPY openvpn.sh /bin/openvpn.sh
WORKDIR /pia

ENV REGION="US East"
ENTRYPOINT ["openvpn.sh"]

HEALTHCHECK --interval=2m --start-period=30s \
     CMD echo "state" | nc localhost 32601 | grep CONNECTED || exit 1
