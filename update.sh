#!/bin/bash

source main.conf
source $CREDENTIALS

if [ "$IPV6" = true ]; then
	CURRENT6=$(curl -6s ip.behrens.io/?ptr=false | head -n 1 | awk '{print $3}')
fi
if [ "$IPV4" = true ]; then
	CURRENT4=$(curl -4s ip.behrens.io/?ptr=false | head -n 1 | awk '{print $3}')
fi

for DOMAIN in "${DOMAINS[@]}"; do
	UPDATEV4=""
	UPDATEV6=""
	if [ "$IPV6" = true ]; then
		DNSV6=$(dig +short AAAA $DOMAIN @8.8.8.8)
		if [ "$CURRENT6" != "$DNSV6" ]; then
			UPDATEV6="&myipv6=$CURRENT6"
		fi
	fi
	if [ "$IPV4" = true ]; then
		DNSV4=$(dig +short A $DOMAIN @8.8.8.8)
		if [ "$CURRENT4" != "$DNSV4" ]; then
			UPDATEV4="&myip=$CURRENT4"
		fi
	fi
	if [ "$UPDATEV4" = "" ] && [ "$UPDATEV6" = "" ]; then
		continue
	fi
	curl "https://api.dynu.com/nic/update?hostname=$DOMAIN$UPDATEV4$UPDATEV6&username=$UPDATEUSER&password=$UPDATEPASS"
done
