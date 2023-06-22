# default vars

COUNTRY="SG"
STATE="Central"
CITY="Singapore"
ORG="My Company"
ORG_UNIT="IT"
COMMON_NAME="www.test.com"
EMAIL="admin@gmail.com"
stunnel="/etc/init.d/stunnel4"
#add ports for easy checking 
clear 
if [[ $(id -u) -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
if [ -f "/usr/bin/ports" ]; then
   echo "Skipped"
else
   apt install net-tools -y
   touch /usr/bin/ports
   chmod +x /usr/bin/ports
   echo "
      netstat -tulpn | grep LISTEN
   " >> /usr/bin/ports
fi
if [ -f "$stunnel" ]; then
   clear
   echo "Reverting changes made by previous script..."

   # Stop and disable udpgw service
   systemctl stop udpgw.service
   systemctl disable udpgw.service

   # Remove udpgw service file
   rm /etc/systemd/system/udpgw.service

   # Remove udpgw binary
   rm /usr/bin/badvpn-udpgw

   # Remove stunnel config and certificate
   rm /etc/stunnel/stunnel.conf
   rm /etc/stunnel/stunnel.pem

   # Remove packages
   apt-get remove --purge dropbear stunnel4 -y

   # Remove /bin/false from shells file
   sed -i '/\/bin\/false/d' /etc/shells

   # Remove user
   systemctl daemon-reload
   clear
   sleep 2
   userdel aku
   echo "Done!"
else
   sleep 2
   echo "[SSH / SSL INSTALLER ]"
   echo "List of things:"
   echo "1. Dropbear"
   echo "2. Stunnel4"
   echo "3. UDPGW" 
   echo "Starting installation ... "
   sleep 3
   clear
   apt-get update -y 
   echo "done 1"
   sleep 3
   apt-get install wget -y
   echo "done 2"
   sleep 3
   apt-get install curl -y
   echo "done 3"
   sleep 3 
   apt-get install dropbear -y  
   echo "done 4"
   sleep 3
   apt-get install stunnel4 -y
   echo "done 5"
   sleep 3
   apt-get install sed -y  
   echo "done 6"
   sleep 3
   sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=21/g' /etc/default/dropbear
   clear
   sleep 3
   echo "Generating certificates for stunnel..."
   openssl req -x509 -newkey rsa:4096 -keyout stunnel.pem -out stunnel.pem -days 365 -nodes -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$ORG_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL" 
   mv stunnel.pem /etc/stunnel/
   touch /etc/stunnel/stunnel.conf
   echo "
   [dropbear]
   accept = 80
   connect = 21
   cert = /etc/stunnel/stunnel.pem
   " >> /etc/stunnel/stunnel.conf
   sleep 3
   echo "Installing UDPGW and service of udpgw.service"
   #!/bin/sh
   OS=`uname -m`;
   wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw" >> /dev/null
   if [ "$OS" == "x86_64" ]; then   
      wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64" >> /dev/null
   fi
   chmod +x /usr/bin/badvpn-udpgw
   # Echo the service file contents
   echo "
   [Unit]
   Description=UDPGW Service
   After=network.target

   [Service]
   Type=simple
   ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300
   Restart=always

   [Install]
   WantedBy=multi-user.target" >> /etc/systemd/system/udpgw.service 
   systemctl daemon-reload
   systemctl enable udpgw.service
   systemctl restart udpgw.service
   sleep 2
   clear
   echo "
   /bin/false" >> /etc/shells
   sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
   systemctl restart stunnel4
   systemctl restart dropbear
   echo "Creating user.."
   sleep 3
   useradd aku -M -s /bin/false
   echo "aku:aku" | chpasswd
   echo "[ SSH Info ]"
   echo "SSL Port: 80"
   echo "Dropbear Port: 22"
   echo "UDPGW Port: 7300"
   clear
   echo "[ User Information ]"
   echo "Username: aku"
   echo "Password: aku"
   sleep 5
   rm /root/install.sh
fi
