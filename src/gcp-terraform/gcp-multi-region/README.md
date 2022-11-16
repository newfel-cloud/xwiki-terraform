## Usage

Before applying the Terraform commands, please add or modify the Terraform variable file as the following example:

- Create a ```tfvars``` file. For example: ```terraform.tfvars```
- Copy and paste the following contents:

```
project_id        = "<your gcp project id>"
region            = "us-west1"
region2           = "us-east1"
availability_type = "REGIONAL"
vm_sa_email       = "<Service account email in your gcp project>"
dns_project_id    = "<DNS project id>"
managed_zone      = "<Name of your DNS zone>"
domain_name       = "<Name of your domain, must end with a trailing dot>"
```

To set up the infrastructure, run Terraform commands in the current folder:

```shell
terraform init
terraform plan
terraform apply 
```

Please refer to [this page](https://cloud.google.com/compute/docs/instances/startup-scripts/linux) for details about how to inspect startup script logs.

To teardown the infrastructure, run:

```shell
terraform destroy
```
