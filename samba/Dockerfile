FROM alpine:3.7
LABEL maintainer "Shyam Sunder <sgsunder1@gmail.com>"

# Get System Depenencies, Set Application User
RUN apk --no-cache add \
        bash \
        samba \
        shadow \
 && adduser -D -G users -H -S -g 'Samba User' -h /tmp smbuser \
 && rm -f /etc/samba/smb.conf \
 && rm -rf /tmp/*

# Copy Files Over
COPY samba.sh /init

# Final Touches
CMD ["/init"]
EXPOSE 137/udp 138/udp 139 445

# Healthcheck to verify server state
HEALTHCHECK --interval=60s --timeout=15s \
  CMD smbclient -L '\\localhost\' -U 'guest%' -m SMB3
