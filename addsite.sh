#!/bin/bash
# start with a fresh terminal
clear

if [ -z $1 ]
then
  exit $E_MISSING_POS_PARAM
fi
DOMAIN="$1"
echo "---------------------------"
echo "    Make new nginx host    "
echo "---------------------------"
echo "         $DOMAIN           "
echo "---------------------------"
echo "     Getting SSL Stuff     "
echo "---------------------------"

/opt/letsencrypt/letsencrypt-auto certonly --email bharesign@gmail.com --text --agree-tos -a webroot --webroot-path /var/www/letsencrypt -d ${DOMAIN}
if [ $? -ne 0 ]
 then
        ERRORLOG=`tail /var/log/letsencrypt/letsencrypt.log`
	echo
	echo
	echo "Domain could not be verified, make sure dns is already set and Nginx is running"
	exit
 else
	cat >> "/etc/cron.monthly/letsencrypt_$DOMAIN.sh" <<EOL
#!/bin/sh
/opt/letsencrypt/letsencrypt-auto certonly --email bharesign@gmail.com --text --agree-tos -a webroot --webroot-path /var/www/letsencrypt --renew-by-default -d $DOMAIN
/etc/init.d/nginx reload
EOL
	
echo "---------------------------"
echo "    ADD LetsEncypt Cron    "
echo "---------------------------"

	chmod +x /etc/cron.monthly/letsencrypt_$DOMAIN.sh

	sed -e "s/__DOMAIN_NAME__/${DOMAIN}/g" /etc/nginx/default_nginx_site.example > "/etc/nginx/conf.d/${DOMAIN}.conf"

	echo "---------------------------"
	echo "       Making Folders      "
	echo "---------------------------"

	mkdir -p /opt/sites/$DOMAIN/public
	# setup an index.php file with phpinfo()
	echo "<?php phpinfo();" > /opt/sites/$DOMAIN/public/index.php
	/etc/init.d/nginx reload
	echo "*********************"
	echo "  Install Complete!  "
	echo "*********************"
	echo "The host is installed and ready to activate."
	cd /opt/sites/$DOMAIN/public
fi

