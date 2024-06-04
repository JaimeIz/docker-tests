FROM neilpang/acme.sh

RUN acme.sh --register-account -m admin@wikicau.duckdns.org

RUN acme.sh --issue --dns dns_duckdns -d wikicau.duckdns.org -d *.wikicau.duckdns.org

ENTRYPOINT ["/entry.sh"]
CMD ["daemon"]