#!/bin/sh -e

# if [[ -f /acme.sh/ ]]

acme.sh --register-account -m admin@wikicau.duckdns.org

acme.sh --issue --dns dns_duckdns -d 'wikicau.duckdns.org'

exec crond -n -s -m off
