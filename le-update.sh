#!/usr/bin/env bash
# HTTPS add into Serverpilot

NC='\033[0m' # No Color    
GREEN='\033[0;32m'

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#==
echo -e ""
echo -e " ##################################################" 
echo -e " ##   THIS SCRIPT WILL UPDATE le-serverpilot     ##"
echo -e " ##                                              ##"
echo -e " ##################################################" 
echo -e ""


echo "Do you want to update LE-SERVERPILOT from the GITHUB (y/n)?"
read DFRUN
if [ $DFRUN == "y" ]; then
    
	echo -e "${GREEN}Updating le-serverpilot...${NC}"
    cd ${SCRIPTDIR}
    git pull

else
	echo -e "${GREEN}Did not update le-serverpilot${NC}"
fi


