#! /bin/bash

## Global Config
SQL_ENDPOINT=$1
FILESTORE_IP_ADDRESS=$2

Config_Xwiki(){
    echo "-----Config jgroup setting to XWiki -----"
    sudo su -c "echo -e \"observation.remote.enabled = true \nobservation.remote.channels = tcp \" | tee -a /etc/xwiki/xwiki.properties"

    echo "-----Config Mysql connection setting to Xwiki -----"
    sudo su -c "sed -i \"s/jdbc:mysql:\/\/xwiki-sql-db/jdbc:mysql:\/\/${SQL_ENDPOINT}/g\" /etc/xwiki/hibernate.cfg.xml"
}

Config_NFS_Xwiki(){
	sudo mkdir -p /mnt/xwiki_file_share_attach 
	sudo chown tomcat:tomcat /mnt/xwiki_file_share_attach
	sudo su -c "echo \"${FILESTORE_IP_ADDRESS}:/xwiki_file_share  /mnt/xwiki_file_share_attach  nfs      defaults  0  0\" | tee -a /etc/fstab"
	sudo mount -a
	
	df -k | grep xwiki || $( echo "The NFS folder was created fail ! " ; exit 1)
}


#############
### Main ####
#############

Config_Xwiki
Config_NFS_Xwiki

echo "-----Restarting tomcat9-----"
sudo systemctl restart tomcat9
sudo systemctl enable tomcat9
echo "-----XWiki has been successfully deployed-----"