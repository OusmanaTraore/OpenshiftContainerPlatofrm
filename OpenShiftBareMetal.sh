#!/bin/bash
source fonctions.sh Config.sh

if [[ -d Downloads ]]
then
    echo " Downloads directory already exists!"
    break
else 
    mkdir Downloads
fi
# Opensfhit installer
echo " | téléchargement de openshift installer >>"
wget  https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-install-linux.tar.gz

line2 

# command line tool CLI
echo " | téléchargement de command line tool CLI >>"
#wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-windows.zip 

wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz

line2

# Red Hat Enterprise Linux CoreOs(RHCOS)
echo " | téléchargement de Red Hat Enterprise Linux CoreOs(RHCOS) >>"
com=`ls | egrep '*.gz2' `
if  [[ $com ]]
then
    mv *.gz *.zip Downloads
    echo " ls Downloads >>"
    ls Downloads
fi
sleep 2 
line2
chooseRHCOS(){
select rhcos in RHCOS_ISO RHCOS_kernel RHCOS_initramfs RHCOS_rootfs 
do
    if [[ $rhcos = "RHCOS_ISO" ]] 
    then
        echo "you choose  to download $rhcos ";
        wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/latest/rhcos-live.x86_64.iso
        break;
    elif [[ $rhcos == "RHCOS_kernel" ]] 
    then
        echo "you choose  to download $rhcos ";
        wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/latest/rhcos-live-kernel-x86_64 
        break;
    elif [[ $rhcos == "RHCOS_initramfs" ]] 
    then
        echo "you choose  to download $rhcos ";
        wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/latest/rhcos-live-initramfs.x86_64.img
        break;
    elif [[ $rhcos == "RHCOS_rootfs" ]] 
    then
        echo "you choose  to download $rhcos ";
        wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/latest/rhcos-live-rootfs.x86_64.img
        break;
    else
        echo "Please select one correct option";
        chooseRHCOS 
        break;
    fi
done
}
chooseRHCOS

# Extraction des fichiers 
echo "Faire appel à une fonction > "
callFunction


# Configuring Zones and masquerading (SNAT) 
echo "Configuring Zones and masquerading (SNAT) "
nmcli connection modify ${interfaceInterne} connection.zone internal
nmcli connection modify ${interfaceExterne} connection.zone external
firewall-cmd --get-active-zones
firewall-cmd --zone=external --add-masquerade --permanent
firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --reload

# Checking Zones  
echo "Checking Zones > "

firewall-cmd --list-all --zone=internal
firewall-cmd --list-all --zone=external

# Preparing the bastion Node
fichier="bationNode.yaml"
keyContinue

# Configuration DNS, DHCP, APACHE ,HAProxy NFS  
echo "Configuration DNS, DHCP, APACHE ,HAProxy NFS > "

# Installation DNS server and its dependencies  
echo "======>>> Installation DNS server and its dependencies > "
dnf install bind bind-utils -y

# Edit the file /etc/named.conf and addind the DnsIp 
fichier="/etc/named.conf"
keyContinue

# Creating the forward  zone file  
echo "======>>> Creating the forward  zone file > "
mkdir /etc/named/zones
fichier="/etc/named/zones/oc.lan"
keyContinue

# Creating the  reverse zone file  
echo "======>>> Creating the  reverse zone file > "
fichier="/etc/named/zones/oc.reserve"
keyContinue

#  Start and enable dns service  
echo " Start and enable dns service > "

systemctl start named
systemctl  enable named

#  Allowing DNS port in firewall 
echo " Allowing DNS port in firewall > "

firewall-cmd --add-port=53/udp --zone=internal --permanent
firewall-cmd --reload


# Configuration du DHCP
echo "======>>> Configuration du DHCP > "

 dnf install -y dhcp-server 

fichier="/etc/dhcp/dhcpd.conf"
keyContinue

#  Start and enable DHCP server 
echo " Start and enable DHCP server > "

systemctl start dhcp
systemctl  enable dhcp

firewall-cmd --add-service=dhcp --zone=internal --permanent
firewall-cmd --reload

# Configuration du Apache Web Server
echo "======>>> Configuration du Apache Web Server > "

 dnf install -y httpd 
echo "======>>> Changing the default port to 8080 > "
sed -i 's/Listen 80/Listen 0.0.0.0:8080/' /etc/httpd/conf/httpd.conf

#  Start and enable  Apache Web Server
echo " Start and enable Apache Web Server  > "

systemctl start httpd
systemctl  enable httpd

firewall-cmd --add-port=dhcp --zone=internal --permanent
firewall-cmd --reload


# Configuring HAProxy 
echo "======>>> Configuring HAProxy > "
dnf install -y haproxy
fichier="/etc/haproxy/haproxy.cfg"
keyContinue

#  Start and enable haproxy  
echo " Start and enable haproxy > "

setsebool -P haproxy_connect_any 1
systemctl start haproxy
systemctl  enable haproxy

#  Allowing haproxy port in firewall 
echo " Allowing haproxy port in firewall > "

firewall-cmd --add-port=6443/tcp --zone=internal --permanent
firewall-cmd --add-port=22623/tcp --zone=internal --permanent
firewall-cmd --add-service=http --zone=internal --permanent
firewall-cmd --add-service=http --zone=external --permanent
firewall-cmd --add-port=6443/tcp --zone=external --permanent
firewall-cmd --add-service=https --zone=internal --permanent
firewall-cmd --add-service=https --zone=external --permanent
firewall-cmd --add-port=9000/tcp --zone=external --permanent
firewall-cmd --reload


# Configuring NFS Server
echo "======>>> Configuration du DHCP > "

 dnf install -y nfs-utils -y 

mkdir -p /shares/registry
chown -R nobody:nobody /shares/registry
chmod -R 777 /shares/registry


fichier="/etc/exports"
keyContinue
# /shares/registry  192.168.110.0/24(rw,sync,root_squash,no_subtree_check,no_wdelay)
exportfs -rv
exporting 192.168.110.0/24:/shares/registry

#  Start and enable DHCP server 
echo " Start and enable DHCP server > "

systemctl start nfs-server rpcbind nfs-mountd
systemctl  enable nfs-server rpcbind 

firewall-cmd --zone=internal --add-service mountd --permanent
firewall-cmd --zone=internal --add-service rpc-bind --permanent
firewall-cmd --zone=internal --add-service nfs --permanent
firewall-cmd --reload