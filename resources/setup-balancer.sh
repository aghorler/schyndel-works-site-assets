#! /bin/bash
# This script was authored by Aaron Horler for a Web Servers and Web Technologies assignment at RMIT in semester two of 2017.

# Configure and enable UFW. This is not strictly required due to the firewall provided by AWS.
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw enable

# Install dependancies.
apt-get update
apt-get -y install build-essential libpcre3-dev libxml2-dev libtool-bin unzip

mkdir -p /etc/apache2/schyndel/server_root/sources/
cd /etc/apache2/schyndel/server_root/sources/

# Download and compile APR.
wget http://apache.mirror.amaze.com.au//apr/apr-1.5.2.tar.gz
gzip -d apr-1.5.2.tar.gz
tar -xvf apr-1.5.2.tar
cd apr-1.5.2
./configure
make
make install

# Download and compile apr-utils.
cd ..
wget http://apache.mirror.amaze.com.au//apr/apr-util-1.5.4.tar.gz
gzip -d apr-util-1.5.4.tar.gz
tar -xvf apr-util-1.5.4.tar
cd apr-util-1.5.4
./configure --with-apr=/usr/local/apr/bin/apr-1-config
make
make install

# Download and compile Apache.
cd ..
wget http://apache.mirror.serversaustralia.com.au//httpd/httpd-2.4.25.tar.gz
gzip -d httpd-2.4.25.tar.gz
tar -xvf httpd-2.4.25.tar
cd httpd-2.4.25
./configure --prefix=/etc/apache2/schyndel/server_root --with-mpm=event --enable-proxy --enable-proxy-http --enable-so --with-port=80
make
make install

# Make Apache start on boot.
sed -i '/exit 0/d' /etc/rc.local
echo "/etc/apache2/schyndel/server_root/bin/apachectl -k start || exit 1" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

# Clear history, because I don't like that.
history -cw

# Start Apache.
bin/apachectl -k start
