#!/bin/bash

# Lets Encrypt sh
RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MYAPP="$1"

    echo -e ""
    echo -e " ###############################################################" 
    echo -e " ##      THIS WILL ISSUE A FREE 90 DAY SSL CERTIFICATE        ##"
    echo -e " ##                     FROM LETS ENCRYPT                     ##"
    echo -e " ###############################################################" 
    echo ""
    
    # Run   

    echo " existing certificates are renewed if older than 14 days"

    if [ "$MYAPP" == '' ]; then
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

    # Check if string is empty using -z.
    if [[ -z "$MYAPP" ]]; then
        echo -e "${RED} ERROR: NO APP ENTERED${NC}"
        exit 1
    else
        #Parse Dir structure for APP
        MYAPP_DIR='/srv/users/serverpilot/apps/'$MYAPP'/public/'
        MYAPPCERT=$SCRIPTDIR'/certs/'$MYAPP'/fullchain.pem'
        MYAPPCONFIG=$SCRIPTDIR'/certs/'$MYAPP'.conf'

        # Lets check if the app exists
        if [ ! -d "$MYAPP_DIR" ]
        then
            echo -e "${RED} ERROR: APP NOT FOUND${NC} - Check your spelling and try again";
            exit;
        else
            if [ -f "$MYAPPCONFIG" ]
            then
                . $MYAPPCONFIG
                MYEMAIL=$email
            else
                echo -e "no config file found. creating one for you."
                echo -e "
    ###############################################################################
    #
    # THIS FILE HAS BEEN AUTO-CREATED FROM LET'S ENCRYPT SERVERPILOT SCRIPT
    # https://github.com/krebbi/le-serverpilot
    #
    ###############################################################################

    email=

    $(cat $MYAPPCONFIG)" > $MYAPPCONFIG
            fi

            if [[ -z "$MYEMAIL" ]]
            then
                echo -e "${GREEN}What is your email address you want to use for ${MYAPP} ? ${NC}"
                read MYEMAIL
                if [[ -z "$MYEMAIL" ]]
                then
                    echo -e "${RED} ERROR: NO EMAIL ENTERED${NC}"
                    exit 1
                else
                    echo -e "Writing the email into the conf now"
                    sed -i "s/\(email *= *\).*/\1$MYEMAIL/" $MYAPPCONFIG
                fi
            else
                echo -e "Using ${MYEMAIL} as Email."
                echo -e "If you want to use another email address, edit ${MYAPPCONFIG}"
            fi



            if [ -f "$MYAPPCERT" ]; then
                bash sp-no-https.sh $MYAPP
            fi

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
                if [[ "$line" == *"server-${MYAPP}"* ]]; then
                    FOUND=1
                fi

            done < /etc/nginx-sp/vhosts.d/$MYAPP.conf

            # All Domains are now in the Array "DOMAINS"

            # Create TMP CONFIG FILE
            echo -e "WELLKNOWN='/srv/users/serverpilot/apps/${MYAPP}/public/.well-known/acme-challenge'" > config.sh
            echo -e "WELLKNOWN2='/srv/users/serverpilot/apps/${MYAPP}/public/.well-known'" >> config.sh
            echo -e "CONTACT_EMAIL='${MYEMAIL}'" >> config.sh
            # Create Domain text
            echo -e "${DOMAINS[@]}" > domains.txt

            #bash letsencrypt.sh -c --app $MYAPP
            bash acme.sh -c -a $MYAPP

            #Remove tmp files
            rm domains.txt
            rm config.sh

            #Activate HTTPS
            bash sp-https.sh $MYAPP

                    
        fi
    fi