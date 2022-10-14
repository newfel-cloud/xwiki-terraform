1. Initialize packages and plugins
  - Use "packer init ." or "packer init xwiki-dev.pkr.hcl"
  - Note that the ".pkr.hcl" is a naming convention for Packer

2. Update variables and credential file
  - export GOOGLE_APPLICATION_CREDENTIALS="{path_to_gcp_service_account_key_file}"
  - Update the values in "xwiki-dev.auto.pkrvars.hcl"
  - Note that the ".pkrvars.hcl" or ".auto.pkrvars.hcl" is a naming convention for Packer

3. Update the configuration files if needed
  - Deployment script: 	xwiki-dev-deploy.sh
  - JGroups config: 	tcp.xml
  - DB config: 		hibernate.cfg.xml
  - XWiki config: 	xwiki.properties

4. Build VM image
  - Use "packer build ." or "packer build xwiki-dev.pkr.hcl"

5. Check VM image
  - Check your image on GCP console: Comput Engine -> Storage -> Images
