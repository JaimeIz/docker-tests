FROM neilpang/acme.sh

RUN acme.sh --issue --dns dns_duckdns -d wikicau.duckdns.org -d *.wikicau.duckdns.org

ENTRYPOINT ["/entry.sh"]
CMD ["daemon"]