#! /bin/bash
# This script was authored by Aaron Horler for a Web Servers and Web Technologies assignment at RMIT in semester two of 2017.

# Configure and enable UFW. This is not strictly required due to the firewall provided by AWS.
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 8050/tcp
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
./configure --prefix=/etc/apache2/schyndel/server_root --with-mpm=event --enable-so --enable-speling --enable-rewrite --enable-include --enable-auth --enable-auth-digest --enable-headers --with-port=8050
make
make install

# Download and compile PHP.
cd ..
wget -O php-7.1.5.tar.gz http://au1.php.net/get/php-7.1.5.tar.gz/from/this/mirror
gzip -d php-7.1.5.tar.gz
tar -xvf php-7.1.5.tar
cd php-7.1.5
./configure --prefix=/etc/apache2/schyndel/server_root/php --with-apxs2=/etc/apache2/schyndel/server_root/bin/apxs --with-config-file-path=/etc/apache2/schyndel/server_root/php
make
make install

# Create document_root directory. Then, download and extract master branch of schyndel-works-site from rohit-lakhanpal on GitHub.
mkdir -p /etc/apache2/schyndel/document_root
cd /etc/apache2/schyndel/document_root
wget https://github.com/rohit-lakhanpal/schyndel-works-site/archive/master.zip
unzip master.zip
rm master.zip
mv -f schyndel-works-site-master/* .
rmdir schyndel-works-site-master

# Correctly set permissions for document_root.
chmod -R 755 /etc/apache2/schyndel/document_root/
chown -R ubuntu: /etc/apache2/schyndel/document_root/

# This is solely for automation. I hosted the configuration files, authored by me, on my personal domain temporarily.
mv /etc/apache2/schyndel/server_root/conf/httpd.conf /etc/apache2/schyndel/server_root/conf/httpd_backup.txt
wget -P /etc/apache2/schyndel/server_root/conf/ https://aaronhorler.com/httpd-b.conf
mv /etc/apache2/schyndel/server_root/conf/httpd-b.conf /etc/apache2/schyndel/server_root/conf/httpd.conf

# Setup authentication using htpasswd.
mkdir /etc/apache2/schyndel/server_root/auth/
cd /etc/apache2/schyndel/server_root/
bin/htpasswd -c auth/basic.pw bob
bin/htpasswd auth/basic.pw charlie
bin/htdigest -c auth/digest.pw secure-digest alice
bin/htdigest auth/digest.pw secure-digest dean

# Make Apache start on boot.
sed -i '/exit 0/d' /etc/rc.local
echo "/etc/apache2/schyndel/server_root/bin/apachectl -k start || exit 1" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

# Clear history, because I don't like that.
history -cw

# Start Apache.
bin/apachectl -k start
