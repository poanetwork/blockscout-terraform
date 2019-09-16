# About

This repo contains scripts designed to automate [Blockscout](https://github.com/poanetwork/blockscout) deployment builds. Currently it supports only AWS as a cloud provider. 

In the root folder you can find an Ansible Playbooks that will create all necessary infrastructure and deploy BlockScout. Please refer to the following sections of README for details:

1. [Deploying the Infrastructure](INFRASTRUCTURE.md). This section describes all the steps to deploy the virtual hardware that is required for production instance of BlockScout. Skip this section if you do have an infrastructure and simply want to install or update your BlockScout. 
2. [Deploying BlockScout](SOFTWARE.md). Follow this section to install or update your BlockScout.
3. [Destroying Provisioned Infrastructure](INFRASTRUCTURE.md#destroying-provisioned-infrastructure). Refer to this section if you want to destroy your BlockScout installation.
4. [Useful information](#useful-information). Refer to this section for unusual use-cases and frequently asked questions.

Also you may want to refer to the `lambda` folder which contains a set of scripts that may be useful in your BlockScout infrastructure.

# Useful information

## Cleaning Deployment cache

Despite the fact that Terraform cache is automatically cleared automatically before each deployment, you may also want to force the cleaning process manually. To do this simply run the `ansible-playbook clean.yml` command, and Terraform cache will be cleared.

## Migrating deployer to another machine

You can easily manipulate your deployment from any machine with sufficient prerequisites. If  `upload_debug_info_to_s3` variable is set to true, the deployer will automatically upload your `all.yml` file to the s3 bucket, so you can easily download it to any other machine. Simply download this file to your `group_vars` folder and your new deployer will pick up the current deployment instead of creating a new one.

## Attaching the existing RDS instance to the current deployment

In some cases you may want not to create a new database, but to add the existing one to use within the deployment. In order to do that configure all the proper values at `group_vars/all.yml` including yours DB ID and name and execute the `ansible-playbook attach_existing_rds.yml` command. This will add the current DB instance into Terraform-managed resource group. After that run `ansible-playbook deploy_infra.yml` as usually. 

**Note 1**:  while executing `ansible-playbook attach_existing_rds.yml` the S3 and DynamoDB will be automatically created (if `backend` variable is set to `true`) to store Terraform state files. 

**Note 2**: the actual name of your resource must include prefix that you will use in this deployment.

Example:

  Real resource: tf-poa

  `prefix` variable: tf

  `db_id` variable: poa

**Note 3**: make sure MultiAZ is disabled on your database.

**Note 4**: make sure that all the variables at `group_vars/all.yml` are exactly the same as at your existing DB.

**Note 5**: currently, deployments scripts does not support attaching the reader instances of Aurora database. Existing readers will be ignored during the deployment process.

## Checking the logs
After the first run of Ansible playbooks the `log.txt` file will be generated at the root of the repo automatically. It will be updated each time you run the playbooks. It is up to you to clean this log file from time to time.

## Common Errors

### S3: 403 error during provisioning
Usually appears if S3 bucket already exists. Remember, S3 bucket has globally unique name, so if you don't have it, it doesn't mean, that it doesn't exists at all. Login to your AWS console and try to create S3 bucket with the same name you specified at `bucket` variable to ensure.
