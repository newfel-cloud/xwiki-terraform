# Installation

Prerequisites:
- A GCP account
- Install Terraform (version >= v1.3.3)
- Install Packer (version >= v1.8.4)
- Install gcloud SDK
- Use ```gcloud auth application-default login``` to set up user credentials

---

# Folder Structure

## packer

This folder contains the automated scripts for creating GCP/AWS VM images with XWiki pre-installed.

## modules

This folder contains Terraform modules for setting up XWiki on GCP.

- networking

    Contains the configurations for IP addresses and firewall rules

- database

    Contains the configurations for  for CloudSQL.

- file-store

    Contains the configurations for Filestore.

- image-builder

    Contains the configurations for Packer.

- vm

    Contains the configurations for Compute Engine and VM Template.

- load-balancer

    Contains the configurations for instance_group, backend_service, auto-scaleing, and frontends setting.


## xwiki-single-region  
  
To deploy the XWiki in single region, please cd to this folder, and then apply the Terraform commands.  
For detailed instruction, please refer to the ```README``` in the ```gcp-single-region``` folder.  
  
## xwiki-multi-region  
  
To deploy the XWiki in multiple regions, please cd to this folder, and then apply the Terraform commands.  
For detailed instruction, please refer to the ```README``` in the ```gcp-multi-region``` folder.  
  
---
