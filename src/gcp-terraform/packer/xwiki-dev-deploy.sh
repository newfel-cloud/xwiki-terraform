#! /bin/bash
echo "-----Deploying XWiki with Packer provisioner-----"

# Configure apt-get for XWiki
echo "-----Configuring apt-get-----"
sudo wget https://maven.xwiki.org/xwiki-keyring.gpg -O /usr/share/keyrings/xwiki-keyring.gpg
sudo wget "https://maven.xwiki.org/stable/xwiki-stable.list" -O /etc/apt/sources.list.d/xwiki-stable.list
sudo apt-get update

# Install and configure MySQL
echo "-----Installing MySQL-----"
sudo apt-get -y install mysql-server-8.0
echo "-----Configuring MySQL-----"
sudo mysql -e "create database xwiki default character set utf8mb4 collate utf8mb4_bin"
sudo mysql -e "create user 'xwiki'@'localhost' identified by 'xwiki'";
sudo mysql -e "grant all privileges on *.* to xwiki@localhost"

# Install and configure XWiki
echo "-----Installing XWiki-----"
sudo apt-get -y install xwiki-tomcat9-common
echo "-----Configuring XWiki-----"
cp /tmp/tcp.xml /usr/lib/xwiki/WEB-INF/observation/remote/jgroups/
cp /tmp/xwiki.properties /etc/xwiki/xwiki.properties
cp /tmp/hibernate.cfg.xml /etc/xwiki/hibernate.cfg.xml

# Configure system script
echo "-----Restarting tomcat9-----"
systemctl restart tomcat9
systemctl enable tomcat9

echo "-----XWiki has been successfully deployed-----"
