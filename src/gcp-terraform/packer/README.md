# Packer Usage

1. Initialize packages and plugins
   - Use "packer init ." or "packer init xwiki.pkr.hcl"
   - Note that the ".pkr.hcl" is a naming convention for Packer

2. Update variables and credential file
   - Execute ```gcloud auth application-default login``` to get the gcp credential in your machine
   - Update the values in ```variables.auto.pkrvars.hcl```
   - Note that the ".pkrvars.hcl" or ".auto.pkrvars.hcl" is a naming convention for Packer

3. Update the configuration files if needed in script* folders
   - Deployment script: xwiki-manual-deploy-gcp.sh
   - JGroups config:  tcp_gcp.xml
   - DB config: hibernate_gcp.cfg.xml

4. Build VM image
   - Use "packer build ." or "packer build xwiki.pkr.hcl"

5. Check VM image
   - Check your image on GCP console: Compute Engine -> Storage -> Images
