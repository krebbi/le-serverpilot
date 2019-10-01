#!/bin/bash
# https://github.com/krebbi/le-serverpilot
# forked from https://github.com/dfinnema/le-serverpilot
# Lets Encrypt sh
RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


function press_enter
{
    echo ""
    echo -n "Press Enter to continue"
    read
    clear
}

selection=
until [ "$selection" = "0" ]; do
    echo -e "${GREEN}"
    echo -e ""
    echo -e " ###############################################################" 
    echo -e " ##   THIS SCRIPT WILL MANAGE LETS ENCRYPT FOR SERVERPILOT    ##"
    echo -e " ##                                                           ##"
    echo -e " ##                ${RED}** USE AT YOUR OWN RISK **${GREEN}                 ##"
    echo -e " ##                                                           ##"
    echo -e " ##                     Version: beta 2.1                     ##"
    echo -e " ###############################################################" 
    echo -e "${NC}"
    echo ""
    echo " ** What would you like to do? **"
    echo ""
    echo "Lets Encrypt Options"
    echo "  1) Issue / Renew a CERT" 
    echo "  2) Revoke a CERT" 
    echo "  3) Delete Lets Encrypt Account Key"
    echo "  4) Manage CRON Jobs"
    echo ""
    echo "Server Pilot Options"
    echo "  8) Activate SSL (issue a cert first)"
    echo "  9) Deactivate SSL"
    echo ""
    echo "Misc"
    echo "  u) Update le-serverpilot"
    echo ""
    echo "  q) Quit"
    echo ""
    echo -n "Enter selection: "
    read selection
    echo ""
    case $selection in
        1 ) bash $SCRIPTDIR/issue-cert.sh; press_enter ;;
        2 ) bash $SCRIPTDIR/revoke-cert.sh; press_enter ;;
        3 ) bash $SCRIPTDIR/le-account.sh; press_enter ;;
        4 ) bash $SCRIPTDIR/sp-cron.sh; press_enter ;;
        8 ) bash $SCRIPTDIR/sp-https.sh; press_enter ;;
        9 ) bash $SCRIPTDIR/sp-no-https.sh; press_enter ;;
        u ) bash $SCRIPTDIR/le-update.sh; press_enter ;;
        q ) exit ;;
        0 ) exit ;;
        * ) echo "Please choose an option"; press_enter
    esac
done
