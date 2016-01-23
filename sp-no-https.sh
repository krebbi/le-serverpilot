# HTTPS add into Serverpilot

RED='\033[0;31m'
NC='\033[0m' # No Color    
GREEN='\033[0;32m'

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


echo "Do you want to remove the custom conf file for HTTPS (y/n)?"
echo -e "${RED} ** this cannot be undone **${NC}"
read DFRUN
if [ $DFRUN == "y" ]; then
	echo "What is your current app name?"
	read MYAPP
    
# Check whether the app exists
    
        #Parse Dir structure for APP
        MYAPP_FILE='/etc/nginx-sp/vhosts.d/'$MYAPP'.custom.conf'
                
        # Lets check if a custom conf exists
        if [ ! -f ${MYAPP_FILE} ]; then echo -e "${RED}CUSTOM CONFIG NOT FOUND${NC} - Check your spelling and try again"; echo "you may have not setup a custom config yet"; exit; fi
        
        
        # Remove the custom files
 
        # START WITH NGINX-SP
        cd /etc/nginx-sp/vhosts.d/
        # We have to create/overwrite any custom files to ensure no errors popup
        rm -f $MYAPP.custom.conf
        # Mve the original config back in place
        mv $MYAPP.conf.orig $MYAPP.conf

        # NOW LETS DO APACHE
        cd /etc/apache-sp/vhosts.d/
        rm -f $MYAPP.custom.conf

        
            #ALL DONE, Lets restart both services
            echo -e "Do you want to ${RED}RESTART${NC} nginx and apache services (y/n)?"
            echo "needed to turn off SSL"
            read DFRUNR
            if [ $DFRUNR == "y" ]; then
                sudo service nginx-sp restart
                sudo service apache-sp restart
                echo -e "${GREEN}All Done! SSL is now disabled${NC}"
                exit;
            else
                echo "No services restarted, config files have been removed"
                echo "both your nginx and apache service needs to be restarted in order for the changes to reflected"
            fi

fi

else
	echo -e "${GREEN}Keep SSL? Left the conf files alone${NC}"
fi
