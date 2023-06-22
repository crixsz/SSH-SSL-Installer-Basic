# default vars

COUNTRY="SG"
STATE="Central"
CITY="Singapore"
ORG="My Company"
ORG_UNIT="IT"
COMMON_NAME="www.test.com"
EMAIL="admin@gmail.com"

clear 
if [[ $(id -u) -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
sleep 2
echo "[SSH / SSL INSTALLER ]"
echo "List of things:"
echo "1. Dropbear"
echo "2. Stunnel4"
echo "3. UDPGW" 
echo "Starting installation ... "
apt-get update -y 
apt-get install wget -y 
apt-get install curl -y 
apt-get install dropbear -y 
apt-get install stunnel4 -y 
apt-get install sed -y 
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=21/g' /etc/default/dropbear
sed -i 's/NO_START=0/NO_START=1/g' /etc/default/dropbear
clear
sleep 3
echo "Generating certificates for stunnel..."
openssl req -x509 -newkey rsa:4096 -keyout stunnel.pem -out stunnel.pem -days 365 -nodes -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$ORG_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL"
mv stunnel.pem /etc/stunnel/
echo -e "
[dropbear]
accept = 80
connect = 21
cert = /etc/stunnel/stunnel.pem
" >> && tee -a /etc/stunnel/stunnel.conf
clear
sleep 3
echo "Installing UDPGW and service of udpgw.service"
#!/bin/sh
OS=`uname -m`;
 wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw" 
if [ "$OS" == "x86_64" ]; then
   wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64" /dev/null
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
echo "Creating user.."
sleep 3
useradd aku -M -s /bin/false
echo "aku:aku" | chpasswd
echo "[ SSH Info ]"
echo "SSL Port: 80"
echo "Dropbear Port: 22"
echo "UDPGW Port: 7300"
echo "[ User Information ]"
echo "Username: aku"
echo "Password: aku"
sleep 5
rm /root/install.sh


