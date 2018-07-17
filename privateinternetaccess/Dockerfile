FROM alpine:latest
LABEL maintainer "Shyam Sunder <sgsunder1@gmail.com>"
LABEL maintainer.upstream "ItsDaSpecialK, colinherbert"
WORKDIR /pia

# Get System Depenencies and VPN configuration
RUN apk --no-cache add \
        openvpn \
        iptables \
        sudo \
 && wget -O /temp.zip \
         "https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip" \
 && unzip /temp.zip -d /pia \
 && rm -f /temp.zip \
 && addgroup -S vpn \
 && echo "root ALL=(ALL:ALL) ALL" > /etc/sudoers

# Copy Initialization Files
COPY openvpn.sh /init

# Final Touches
ENTRYPOINT ["/init"]

# Assume a default region
ENV REGION="US East"

# Healthcheck to verify VPN state
HEALTHCHECK --interval=2m --start-period=30s \
  CMD echo "state" | nc localhost 32601 | grep CONNECTED || exit 1
