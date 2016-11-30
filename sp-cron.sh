#!/usr/bin/env bash
# HTTPS add into Serverpilot

RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'
STS=""
MYAPP="$1"
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


#==

echo -e "${GREEN}"
echo -e ""
echo -e " ###############################################################" 
echo -e " ##               THIS WILL MANAGE YOUR CRON-JOBS             ##"
echo -e " ##                                                           ##"
echo -e " ##                 ${NC}** USE AT YOUR OWN RISK **${GREEN}                ##"
echo -e " ##                                                           ##"
echo -e " ###############################################################" 
echo -e "${NC}"

if [ "$MYAPP" == '' ]; then
	echo "For what App do you want to create an automatic cert renewal?"
	echo "(Green Apps do have an active CRON)"
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
                CHECKCRON='/etc/cron.weekly/le-'${APP#$APPS/}
                if [ -f "$CHECKCRON" ];
                    then
                    echo -e $MYAPPCOUNT") " "${GREEN}"${APP#$APPS/}"${NC}"
                    else
                    echo -e $MYAPPCOUNT") " ${APP#$APPS/}
                fi
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
    MYAPPCRON='/etc/cron.weekly/le-'$MYAPP

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

" > $MYAPPCONFIG
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

        if [ -f "$MYAPPCRON" ];
            then
            echo -e "${RED}cronjob already exists. deleting.${NC}"
            rm $MYAPPCRON
            else
            echo -e "${GREEN}cronjob not found. creating.${NC}"
            echo -e "#!/bin/sh
${SCRIPTDIR}/issue-cert.sh ${MYAPP}" > $MYAPPCRON
            chmod +x $MYAPPCRON
        fi

    fi
fi