#! /bin/bash

Install(){
	echo "-----Configuring apt-get-----"
	sudo wget https://maven.xwiki.org/xwiki-keyring.gpg -O /usr/share/keyrings/xwiki-keyring.gpg
	sudo wget "https://maven.xwiki.org/stable/xwiki-stable.list" -O /etc/apt/sources.list.d/xwiki-stable.list
	sudo apt-get update

	echo "-----Installing Network Tools-----"
	sudo apt-get install net-tools nfs-common -y

	echo "-----Installing MySQL-----"
	sudo apt-get -y install mysql-client-core-8.0

	echo "-----Installing XWiki-----"
	sudo apt-get -y install xwiki-tomcat9-common

}

#############
### Main ####
#############

while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done

Install
sudo cp /tmp/tcp_aws.xml /usr/lib/xwiki/WEB-INF/observation/remote/jgroups/tcp.xml
sudo cp /tmp/hibernate_aws.cfg.xml /etc/xwiki/hibernate.cfg.xml
sudo cp /tmp/startup.sh /home/startup.sh


