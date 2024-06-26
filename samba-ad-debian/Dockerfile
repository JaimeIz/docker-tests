FROM debian:12-slim

ENV ADMIN_PASSWORD_SECRET=samba-admin-password \
    BIND_INTERFACES_ONLY=yes \
    ALLOW_LDAP_INSECURE=false \
    ALLOW_DNS_UPDATES=secure \
    DOMAIN_ACTION=provision \
    DOMAIN_LOGONS=yes \
    DOMAIN_MASTER=no \
    INTERFACES="lo eth0" \
    LOG_LEVEL=1 \
    MODEL=standard \
    NETBIOS_NAME= \
    REALM=SAMDOM.EXAMPLE.COM \
    DOMAIN=SAMDOM \
    WORKGROUP=AD \
    WINBIND_USE_DEFAULT_DOMAIN=yes \
    SERVER_STRING="Samba Domain Controller" \
    TZ=UTC

RUN apt update \
    && apt install -y \
        acl \
        ntp \
        attr \
        sssd \
        samba smbclient \ 
        winbind libnss-winbind libpam-winbind \
        ldb-tools ldap-utils \ 
        bind9 bind9utils dnsutils \
        krb5-user krb5-kdc libpam-krb5 \
        openssl ca-certificates certbot \
        pwgen expect \
        supervisor \
        rsyslog pkg-config \
        inetutils-ping \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log} \
    && rm -fr /tmp/* /var/tmp/*

COPY scripts/kdb5_util_create.expect /root/kdb5_util_create.expect
COPY scripts/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY scripts /root
RUN chmod -R 500 /root
    
VOLUME [ "/var/lib/samba", "/var/lib/krb5kdc", "/etc/samba", "/etc/bind"]
EXPOSE 53 53/udp 88 88/udp 135 137-138/udp 139 389 389/udp 445 464 464/udp 636 3268-3269 49152-65535

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["app:start"]
    