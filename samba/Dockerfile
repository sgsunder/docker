FROM alpine:3.7
LABEL maintainer "Shyam Sunder <sgsunder1@gmail.com>"

# Get System Depenencies
RUN apk --no-cache add \
        bash \
        samba \
        shadow \
 && adduser -D -G users -H -S -g 'Samba User' -h /tmp smbuser \
 && rm -f /etc/samba/smb.conf \
 && rm -rf /tmp/*

# Copy Files Over
COPY smb.conf /etc/samba/
COPY samba.sh samba-reader.sh /usr/bin/

# Final Touches
CMD ["/usr/bin/samba-reader.sh"]
EXPOSE 137/udp 138/udp 139 445

# Healthcheck to verify server state
HEALTHCHECK --interval=60s --timeout=15s \
  CMD smbclient -L '\\localhost\' -U 'guest%' -m SMB3
