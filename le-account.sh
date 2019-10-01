# Deletes the private Lets Encrypt account key

NC='\033[0m' # No Color    
GREEN='\033[0;32m'
RED='\033[0;31m'

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#==
echo -e "${RED}"
echo -e " ##################################################" 
echo -e " ##             This will remove your            ##"
echo -e " ##           Lets Encrypt account key           ##"
echo -e " ##################################################" 
echo -e "${NC}"


echo -e "Do you want to ${RED}DELETE${NC} LE-SERVERPILOT private account key (y/n)?"
read DFRUN
if [ $DFRUN == "y" ]; then
    echo ""
	echo -e " + Deleting Account Key..."
    cd ${SCRIPTDIR}
    rm "private_key.pem"
    echo " DONE"
else
	echo -e "${GREEN}Did not delete account information${NC}"
fi


