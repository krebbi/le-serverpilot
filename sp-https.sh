# HTTPS add into Serverpilot

RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'
STS=""

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# directory for config, private key and certificates
BASEDIR="${SCRIPTDIR}"

#==

echo -e "${GREEN}"
echo -e ""
echo -e " ###############################################################" 
echo -e " ##   THIS WILL ADD HTTPS TO A CUSTOM VHOST FOR SERVERPILOT   ##"
echo -e " ##                                                           ##"
echo -e " ##             ${NC}** USE AT YOUR OWN RISK **${GREEN}       ##"
echo -e " ##                                                           ##"
echo -e " ###############################################################" 
echo -e "${NC}"

echo "Do you want to add a custom conf file for HTTPS (y/n)?"
read DFRUN
if [ $DFRUN == "y" ]; then
	echo "What is your current app name?"
	read MYAPP
	#echo "What is the domain name you want to use?"
    #echo " - the one you issued your ssl cert for"
	#read MYDOMAIN
    echo "Do you want to add 6 Month Policy Strict-Transport-Security (y/n)?"
    echo " - helps prevent protocol downgrade attacks"
    read DFSTSA1
    
# Check whether a cert has been issued

    #Parse Dir structure for APP
    MYDOMAIN_DIR="${BASEDIR}/certs/${MYAPP}"

    # Lets check if the app exists
    if [ ! -d "$MYDOMAIN_DIR" ]; then
        echo -e "${RED}DOMAIN CERT NOT FOUND${NC} - Check your spelling and try again";
        echo -e " - make sure you issued your certificate before running this";
        exit;
    else
    
        #Parse Dir structure for APP
        MYAPP_DIR='/srv/users/serverpilot/apps/'$MYAPP'/public/'
                
        # Lets check if the app exists
        if [ ! -d "$MYAPP_DIR" ]; then
            echo -e "${RED}APP NOT FOUND${NC} - Check your spelling and try again";
            exit;
        else

        if [ $DFSTSA1 == "y" ]; then
            echo " + Adding Strict-Transport-Security 6 Month Policy"
            STS="add_header Strict-Transport-Security max-age=15768000;"
        fi

        #== NGINX CUSTOM CONFIG ==
        #!/bin/sh

        # START WITH NGINX-SP
        cd
        cd /etc/nginx-sp/vhosts.d/

        # Let's get all Domains from the APP

        DOMAINS=()
        FOUND=0
        while IFS='' read -r line || [[ -n "$line" ]]; do
            if [ "$FOUND" == 1 ]
                then
                if [[ "$line" == *";"* ]]
                    then
                        FOUND=0
                    else
                        FOUNDDOMAIN="${line#"${line%%[![:space:]]*}"}"
                        FOUNDDOMAIN="${FOUNDDOMAIN%"${FOUNDDOMAIN##*[![:space:]]}"}"
                        DOMAINS=("${DOMAINS[@]}" "$FOUNDDOMAIN")
                fi
            fi
            if [[ "$line" == *"server_name"* ]]
                then
                    FOUND=1
            fi

        done < /etc/nginx-sp/vhosts.d/$MYAPP.conf
        
        # All Domains are now in the Array "DOMAINS"

        # We have to copy the default config to have a config with all domain entries so we don't have to create them again
        cp $MYAPP.conf $MYAPP.custom.conf

        # We need to rename the original conf-file so it isn't used by nginx
        mv $MYAPP.conf $MYAPP.conf.orig

        #Let's inject a 301-redirect from port 80 to 443
        sed -i 's/\[\:\:\]\:80\;/\[\:\:\]\:80\;return 301 https\:\/\/\$host\$request_uri\;/g' $MYAPP.custom.conf
        
        # Let's create a new beginning to the config file

        echo -e "
###############################################################################
# DO NOT EDIT THIS FILE.
#
# THIS FILE HAS BEEN AUTO-MODIFIED FROM LET'S ENCRYPT SERVERPILOT SCRIPT
# https://github.com/dfinnema/le-serverpilot
###############################################################################

$(cat $MYAPP.custom.conf)" > $MYAPP.custom.conf

# now we're adding the new SSL part to the end of the copied conf

echo -e "

server 
{
    listen   443 ssl http2;
    server_name
    " >> $MYAPP.custom.conf

# now we iterate through the available DOMAINS and add them

for i in "${DOMAINS[@]}"
do
   echo -e "        $i">> $MYAPP.custom.conf
done

# Now the remaining stuff we need

echo -e "
    ;
    root   /srv/users/serverpilot/apps/$MYAPP/public;
    
    ssl on;
    ssl_certificate ${MYDOMAIN_DIR}/fullchain.pem;
    ssl_certificate_key ${MYDOMAIN_DIR}/privkey.pem;
    ssl_session_timeout 5m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH;
    ssl_session_cache shared:SSL:50m;
    
    # EXTRA SECURITY HEADERS
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection \"1; mode=block\;\";
    ${STS}
    
    access_log  /srv/users/serverpilot/log/$MYAPP/${MYAPP}_nginx.access.log  main;
    error_log  /srv/users/serverpilot/log/$MYAPP/${MYAPP}_nginx.error.log;
    
    proxy_set_header    Host  \$host;
    proxy_set_header    X-Real-IP         \$remote_addr;
    proxy_set_header    X-Forwarded-For   \$proxy_add_x_forwarded_for;
    proxy_set_header    X-Forwarded-SSL on;
    proxy_set_header    X-Forwarded-Proto \$scheme;
    
    include /etc/nginx-sp/vhosts.d/$MYAPP.d/*.nonssl_conf;
    include /etc/nginx-sp/vhosts.d/$MYAPP.d/*.conf;
}
" >> $MYAPP.custom.conf

        # NOW LETS DO APACHE
        cd
        cd /etc/apache-sp/vhosts.d/

        # We have to copy the default config to have a config with all domain entries so we don't have to create them again
        cp $MYAPP.conf $MYAPP.custom.conf

        # We need to rename the original conf-file so it isn't used by apache
        mv $MYAPP.conf $MYAPP.conf.orig

        # Let's create a new beginning to the config file

        echo -e "
###############################################################################
# DO NOT EDIT THIS FILE.
#
# THIS FILE HAS BEEN AUTO-MODIFIED FROM LET'S ENCRYPT SERVERPILOT SCRIPT
# https://github.com/dfinnema/le-serverpilot
###############################################################################

$(cat $MYAPP.custom.conf)" > $MYAPP.custom.conf

# now we're adding the new SSL part to the end of the copied conf

echo -e "

<VirtualHost 127.0.0.1:443>
    Define DOCUMENT_ROOT /srv/users/serverpilot/apps/${MYAPP}/public
    
    ServerAdmin webmaster@
    DocumentRoot \${DOCUMENT_ROOT}
    ServerName server-${MYAPP}" >> $MYAPP.custom.conf

# now we iterate through the available DOMAINS and add them

for i in "${DOMAINS[@]}"
do
   echo -e "    ServerAlias $i">> $MYAPP.custom.conf
done

# Now the remaining stuff we need


        echo -e "

    SSLEngine on
    SSLProtocol all -SSLv2
    SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM
    
    SSLCertificateFile ${MYDOMAIN_DIR}/fullchain.pem
    SSLCertificateKeyFile ${MYDOMAIN_DIR}/privkey.pem
    SSLCertificateChainFile ${MYDOMAIN_DIR}/fullchain.pem
    
    RemoteIPHeader X-Real-IP
    SetEnvIf X-Forwarded-SSL on HTTPS=on
    
    ErrorLog \"/srv/users/serverpilot/log/${MYAPP}/${MYAPP}_apache.error.log\"
    CustomLog \"/srv/users/serverpilot/log/${MYAPP}/${MYAPP}_apache.access.log\" common
    
</VirtualHost>" >> $MYAPP.custom.conf
        
            #ALL DONE, Lets restart both services
            echo -e "Do you want to ${RED}RESTART${NC} nginx and apache services (y/n)?"
            read DFRUNR
            if [ $DFRUNR == "y" ]; then
                sudo service nginx-sp restart
                sudo service apache-sp restart
                echo -e "${GREEN}All Done! SSL is now enabled for Lets Encrypt${NC}"
                exit;
            else
                echo "No services restarted, SSL config has been setup."
                echo "both your nginx and apache service needs to be restarted to be enabled"
            fi
        
        fi

fi

else
	echo -e "${GREEN}No SSL? Left the conf files alone${NC}"
fi
