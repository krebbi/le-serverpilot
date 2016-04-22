# le-serverpilot
SH script to install / manage Lets Encrypt for Server Pilot free users

differences to dfinnema/le-serverpilot:

This fork takes all domains from the serverpilot config and issues / renews the certs accordingly. 
no need to type in all the domains manually.


#** PLEASE USE AT YOUR OWN RISK **

##Requirements

 Ubuntu 14.04 
 Server running with Serverpilot
 Root User Access

##How to Install

```
git clone https://github.com/dfinnema/le-serverpilot.git
cd le-serverpilot
chmod +x df.sh
chmod +x sp-https.sh
chmod +x sp-no-https.sh
```

##How to Use

```
cd le-serverpilot
./df.sh
```

## Misc

Please note this is a fork of dfinnema/le-serverpilot

### FAQ

Q: Does this need to be run as ROOT

A: Yes at this time it requires ROOT or SUDO access as it needs to edit APACHE and NGINX configurations

Q: Where does it store the SSL files 

A: in a sub directory called 'certs' (eg; le-serverpilot/certs/)

Q: Where does it store my Lets Encrypt account 

A: in the le-serverpilot directory under a file called 'private_key.pem' 

Q: Does this use the official Lets Encrypt client

A: No it uses a very usefull script from (https://github.com/lukas2511/letsencrypt.sh) to do the heavy lifting



