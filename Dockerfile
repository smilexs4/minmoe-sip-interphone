FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends asterisk curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Only these files are overridden; every other default config shipped by the
# debian package (indications.conf, musiconhold.conf, modules.conf, ...) is
# left in place so Asterisk still has everything it needs to boot.
COPY asterisk-config/pjsip.conf   /etc/asterisk/pjsip.conf
COPY asterisk-config/extensions.conf /etc/asterisk/extensions.conf
COPY asterisk-config/features.conf   /etc/asterisk/features.conf
COPY asterisk-config/logger.conf     /etc/asterisk/logger.conf
COPY asterisk-config/rtp.conf        /etc/asterisk/rtp.conf

COPY scripts/open_door.sh /usr/local/bin/open_door.sh
RUN chmod +x /usr/local/bin/open_door.sh

EXPOSE 5060/udp 5060/tcp 10000-20000/udp

CMD ["asterisk", "-f", "-vvv"]
