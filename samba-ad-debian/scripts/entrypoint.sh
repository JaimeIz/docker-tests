#!/bin/bash

set -e

SETUP_LOCK_FILE="/var/lib/samba/private/.setup.lock.do.not.remove"

if [ -z "$NETBIOS_NAME" ]; then
  NETBIOS_NAME=$(hostname -s | tr [a-z] [A-Z])
else
  NETBIOS_NAME=$(echo $NETBIOS_NAME | tr [a-z] [A-Z])
fi

if [ ! -f /etc/timezone ] && [ ! -z "$TZ" ]; then
  echo 'Set timezone'
  cp /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ >/etc/timezone
fi

REALM=$(echo "$REALM" | tr [a-z] [A-Z])

WORKGROUP=$(echo "$WORKGROUP" | tr [a-z] [A-Z])

if [[ $HOST_IP ]]; then
    HOST_IP="--host-ip=${HOST_IP}"
fi

appSetup () {
	echo "Initializing samba database..."

	SAMBA_PASSWORD=${SAMBA_PASSWORD:-$(pwgen -cny 10 1)}
	export KERBEROS_PASSWORD=${KERBEROS_PASSWORD:-$(pwgen -cny 10 1)}
	echo Samba administrator password: $SAMBA_PASSWORD
	echo Kerberos KDC database master key: $KERBEROS_PASSWORD

	# Provision Samba
	rm -f /etc/samba/smb.conf
	rm -rf /var/lib/samba/*
	mkdir -p /var/lib/samba/private
	samba-tool domain provision \
		--use-rfc2307 \
		--domain=$DOMAIN \
		--realm=$REALM \
		--server-role=dc\
		--dns-backend=BIND9_DLZ \
		--adminpass=$SAMBA_PASSWORD
		$HOST_IP

  	echo "!root = $NETBIOS_NAME\Administrator" > /etc/samba/user.map

	mkdir -p -m 700 /etc/samba/conf.d

	source /root/.templates
	echo "$SMBCONF" > /etc/samba/smb.conf
	echo "$NETLOGON" > /etc/samba/conf.d/netlogon.conf
	echo "$SYSVOL" > /etc/samba/conf.d/sysvol.conf

	for file in $(ls -A /etc/samba/conf.d/*.conf); do
		echo "include = $file" >> /etc/samba/smb.conf
	done
    
	# Config kerberos
	cp /var/lib/samba/private/krb5.conf $KRB5_CONFIG
    
	# Create Kerberos database
    expect /root/kdb5_util_create.expect

    # Export kerberos keytab for use with sssd
	samba-tool domain exportkeytab /etc/krb5.keytab --principal ${NETBIOS_NAME}\$
    
	# Configure BIND9
	cp /root/bind/named.conf /etc/bind/named.conf
	cp /root/bind/named.conf.options /etc/bind/named.conf.options
	chgrp -R bind /var/lib/samba/bind-dns
	chown -R bind:bind /etc/bind

	CERTS_DIR="/usr/local/samba/private/tls"
	mkdir -p -m 700 $CERTS_DIR

	openssl req -nodes -x509 -newkey rsa:2048 -keyout $CERTS_DIR/ca.key -out $CERTS_DIR/ca.crt -subj "/C=ES/ST=HUESCA/L=HUESCA/O=Dis/CN=$REALM"
	openssl req -nodes -newkey rsa:2048 -keyout $CERTS_DIR/server.key -out $CERTS_DIR/server.scr  -subj "/C=ES/ST=HUESCA/L=HUESCA/O=Dis/CN=$HOST.$REALM"
	openssl x509 -req -in $CERTS_DIR/server.scr -days 365 -CA $CERTS_DIR/ca.crt -CAkey $CERTS_DIR/ca.key -CAcreateserial -out $CERTS_DIR/server.crt

	source /root/.templates
	echo "$SMBCONF" > /etc/samba/smb.conf
	echo "$NETLOGON" > /etc/samba/conf.d/netlogon.conf
	echo "$SYSVOL" > /etc/samba/conf.d/sysvol.conf
	echo "$KRB5CONF" > /etc/krb5.conf

    touch "${SETUP_LOCK_FILE}"
}

appStart () {
    if [ ! -f "${SETUP_LOCK_FILE}" ]; then
      appSetup
    fi
    samba -i
#    /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
}

appHelp () {
	echo "Available options:"
	echo " app:start          - Starts all services needed for Samba AD DC"
	echo " app:setup          - First time setup."
	echo " app:setup_start    - First time setup and start."
	echo " app:help           - Displays the help"
	echo " [command]          - Execute the specified linux command eg. /bin/bash."
}

case "$1" in
	app:start)
		appStart
		;;
	app:setup)
		appSetup
		;;
	app:setup_start)
		appSetup
		appStart
		;;
	app:help)
		appHelp
		;;
	*)
		if [ -x $1 ]; then
			$1
		else
			prog=$(which $1)
			if [ -n "${prog}" ] ; then
				shift 1
				$prog $@
			else
				appHelp
			fi
		fi
		;;
esac

exit 0
