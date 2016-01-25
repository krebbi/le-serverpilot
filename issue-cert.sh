#!/bin/bash

# Lets Encrypt sh
RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'


    echo -e ""
    echo -e " ###############################################################" 
    echo -e " ##      THIS WILL ISSUE A FREE 90 DAY SSL CERTIFICATE        ##"
    echo -e " ##                     FROM LETS ENCRYPT                     ##"
    echo -e " ###############################################################" 
    echo ""
    
    # Run   
    
    echo -e "${GREEN}Do you want to issue/renew a SSL certificate (y/n)?${NC}"
    echo " existing certificates are renewed if older than 14 days"
    read DFRUN
    if [ $DFRUN == "y" ]; then
        
        echo -e "${GREEN}What is your email address you want to use for Lets Encrypt${NC}"
        read MYEMAIL
                
        # Check if string is empty using -z. For more 'help test'    
        if [[ -z "$MYEMAIL" ]]; then
            echo -e "${RED} ERROR: NO EMAIL ENTERED${NC}"
            exit 1
        fi
    
    
        echo -e "${GREEN}What is your current app name?${NC}"
        read MYAPP
                
            # Check if string is empty using -z. For more 'help test'    
            if [[ -z "$MYAPP" ]]; then
               echo -e "${RED} ERROR: NO APP ENTERED${NC}"
               exit 1
            else
                 #Parse Dir structure for APP
                MYAPP_DIR='/srv/users/serverpilot/apps/'$MYAPP'/public/'
                
                 # Lets check if the app exists
                if [ ! -d "$MYAPP_DIR" ]; then
                #if [  -d "$MYAPP_DIR" ]; then
                    echo -e "${RED} ERROR: APP NOT FOUND${NC} - Check your spelling and try again";
                    exit;
                else
                    #echo -e "${GREEN}Which domain name do wish to use for this cert?${NC}"
                    #read MYDOMAIN
                    
                    #if [[ -z "$MYDOMAIN" ]]; then
                    #    echo -e "${RED} ERROR: No Domain Entered${NC}";
                    #    exit;
                    #else
                        # Check if the Domain Exists
                    #     if [[ $(wget http://${MYDOMAIN}/ -O-) ]] 2>/dev/null
                    #      then echo " + Domain Valid"
                    #      else echo -e "${RED} ERROR: Invalid Domain${NC}";
                    #      exit;
                    #     fi
                    
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

                        # Create TMP CONFIG FILE
                        echo -e "WELLKNOWN='/srv/users/serverpilot/apps/${MYAPP}/public/.well-known/acme-challenge'" > config.sh
                        echo -e "WELLKNOWN2='/srv/users/serverpilot/apps/${MYAPP}/public/.well-known'" >> config.sh
                        echo -e "CONTACT_EMAIL='${MYEMAIL}'" >> config.sh
                        # Create Domain text
                        echo -e "${DOMAINS[@]}" > domains.txt
                        
                        bash acme.sh -c -a $MYAPP
                        
                        #Remove tmp files
                        rm domains.txt
                        rm config.sh
                    #fi
                    
                fi
            fi
        
    else
    echo "Nothing issued!"
	exit;
    fi
    
    
