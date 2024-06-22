FROM neilpang/acme.sh

ENV DuckDNS_Token=${DuckDNS_Token}

COPY setup.sh /

RUN chmod +x /setup.sh /acme.sh

ENTRYPOINT ["/setup.sh"]