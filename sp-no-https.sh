#!/usr/bin/env bash
# HTTPS add into Serverpilot

RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'
MYAPP="$1"

#==
echo -e "${RED}"
echo -e ""
echo -e " ###############################################################" 
echo -e " ##     THIS WILL REMOVE THE CUSTOM VHOST FOR SERVERPILOT     ##"
echo -e " ##                                                           ##"
echo -e " ##             ${NC}** USE AT YOUR OWN RISK **${RED}                    ##"
echo -e " ##                                                           ##"
echo -e " ###############################################################" 
echo -e "${NC}"

if [ "$MYAPP" == '' ]
  then
   MYAPPCOUNT=0
        for ENTRY in "/srv/users"/*
        do
            APPS=$ENTRY"/apps"
            echo -e ""
            echo -e "${ENTRY#/srv/users/}"
            echo -e ""
            for APP in $APPS/*
            do
                ((MYAPPCOUNT++))
                echo $MYAPPCOUNT") " ${APP#$APPS/}
                MYAPPS[$MYAPPCOUNT]=${APP#$APPS/}
            done
        done
        echo -e "${GREEN}Please choose App${NC}"
        read MYAPPNUMBER
        echo ""
        MYAPP=${MYAPPS[$MYAPPNUMBER]}
fi
    
# Check whether the app exists
    
        #Parse Dir structure for APP
        MYAPP_FILE='/etc/nginx-sp/vhosts.d/'$MYAPP'.custom.conf'
                
        # Lets check if a custom conf exists
        if [ ! -f ${MYAPP_FILE} ]; then echo -e "${RED}CUSTOM CONFIG NOT FOUND${NC} - Check your spelling and try again"; echo "you may have not setup a custom config yet"; exit; fi

        # Remove the custom files
 
        # START WITH NGINX-SP
        echo -e "proccessing nginx"
        cd /etc/nginx-sp/vhosts.d/
        # We have to create/overwrite any custom files to ensure no errors popup
        rm -f $MYAPP.custom.conf
        # Move the original config back in place
        mv $MYAPP.conf.orig $MYAPP.conf

        # NOW LETS DO APACHE
        echo -e "proccessing Apache"
        cd /etc/apache-sp/vhosts.d/
        rm -f $MYAPP.custom.conf
        # Move the original config back in place
        mv $MYAPP.conf.orig $MYAPP.conf

        sudo service nginx-sp restart
        sudo service apache-sp restart
        echo -e "${GREEN}All Done! SSL is now disabled${NC}"
        exit;

fi
