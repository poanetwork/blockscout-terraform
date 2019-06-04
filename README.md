# About

This repo contains scripts designed to automate [Blockscout](https://github.com/poanetwork/blockscout) deployment builds. Currently it supports only [AWS](#AWS) as a cloud provider. 

In the root folder you can find an Ansible Playbooks that will create all necessary infrastructure and deploy BlockScout. Please refer to the following sections of the README for details:

1. [Deploying the Infrastructure](#deploying-the-infrastructure). This section describes all the steps to deploy the virtual hardware that is required for production instance of BlockScout. Skip this section if you do have an infrastructure and simply want to install or update your BlockScout. 
2. [Deploying BlockScout](#deploying-blockscout). Follow this section to install or update your BlockScout.
3. [Destroying Provisioned Infrastructure](#destroying-provisioned-infrastructure). Refer to this section if you want to destroy your BlockScout installation.

Also you may want to refer to the `lambda` folder which contains a set of scripts that may be useful in your BlockScout infrastructure.

# Prerequisites

Playbooks relies on Terraform under the hood, which is the stateful infrastructure-as-a-code software tool. It allows to keep a hand on your infrastructure - modify and recreate single and multiple resources depending on your needs.

This version of playbooks supports the multi-hosts deployment, which means that test BlockScout instances can be built on remote machines. In that case, you will need to have the Ansible, installed on jumpbox (controller) and all the prerequisites, that are described below, installed on runners.

## Prerequisites for deploying infrastructure

| Dependency name                        | Installation method                                          |
| -------------------------------------- | ------------------------------------------------------------ |
| Terraform >=0.11.11                    | [Installation guide](https://learn.hashicorp.com/terraform/getting-started/install.html) |
| Python >=2.6.0                         | `apt install python`                                         |
| Python-pip                             | `apt install python-pip`                                     |
| boto & boto3 & botocore python modules | `pip install boto boto3 botocore`                            |

## Prerequisites for deploying BlockScout

| Dependency name                        | Installation method                                          |
| -------------------------------------- | ------------------------------------------------------------ |
| Terraform >=0.11.11                    | [Installation guide](https://learn.hashicorp.com/terraform/getting-started/install.html) |
| Python >=2.6.0                         | `apt install python`                                         |
| Python-pip                             | `apt install python-pip`                                     |
| boto & boto3 & botocore python modules | `pip install boto boto3 botocore`                            |
| AWS CLI                                | `pip install awscli`                                         |
| All BlockScout prerequisites           | [Check it here](https://github.com/poanetwork/blockscout#requirements) |


# AWS permissions

During deployment you will have to provide credentials to your AWS account. Deployment process requires a wide set of permissions to do the job, so it would work best of all if you specify the administrator account credentials. 

However, if you want to restrict the permissions as much possible, here is the list of resources which are created during the deployment process:

- An S3 bucket to keep Terraform state files;
- DynamoDB table to manage Terraform state files leases;
- An SSH keypair (or you can choose to use one which was already created), this is used with any EC2 hosts;
- A VPC containing all of the resources provisioned;
- A public subnet for the app servers, and a private subnet for the database (and Redis for now);
- An internet gateway to provide internet access for the VPC;
- An ALB which exposes the app server HTTPS endpoints to the world;
- A security group to lock down ingress to the app servers to 80/443 + SSH;
- A security group to allow the ALB to talk to the app servers;
- A security group to allow the app servers access to the database;
- An internal DNS zone;
- A DNS record for the database;
- An autoscaling group and launch configuration for each chain;
- A CodeDeploy application and deployment group targeting the corresponding autoscaling groups.

Each configured chain will receive its own ASG (autoscaling group) and deployment group, when application updates are pushed to CodeDeploy, all autoscaling groups will deploy the new version using a blue/green strategy. Currently, there is only one EC2 host to run, and the ASG is configured to allow scaling up, but no triggers are set up to actually perform the scaling yet. This is something that may come in the future.

The deployment process goes in two stages. First, Ansible creates S3 bucket and DynamoDB table that are required for Terraform state management. It is needed to ensure that Terraforms state is stored in a centralized location, so that multiple people can use Terraform on the same infra without stepping on each others toes. Terraform prevents this from happening by holding locks (via DynamoDB) against the state data (stored in S3). 

# Configuration
There are three groups of variables required to build BlockScout. Furst is required to create infrastructure, second is required to build BlockScout instances and the third is the one that is required both for infra and BS itself.
For your convenience we have divided variable templates into three files accordingly - `infrastructure.yml.example`, `blockscout.yml.example` and `all.yml.example` . Also we have divided those files to place them in `group_vars` and in `host_vars` folder, so you will not have to repeat some of the variables for each host/group. 

In order to deploy BlockScout, you will have to setup the following set of files for each BlockScout instance:

```
/
| - group_vars
|   | - group.yml (combination of [blockscout+infrastructure+all].yml.example)
|   | - all.yml (optional)
| - host_vars
|   | - host.yml (combination of [blockscout+infrastructure+all].yml.example)
| - hosts
```

## Common variables

- `ansible_host` - is an address where BlockScout will be built. If this variable is set to localhost, also set `ansible_connection` to `local` for better performance.
- `chain` variable set the name of the network (Kovan, Core, xDAI, etc.). Will be used as part of the infrastructure resource names.
- `env_vars` represents a set of environment variables used by BlockScout. You can see the description of this variables at [POA Forum](https://forum.poa.network/t/faq-blockscout-environment-variables/1814).
- `aws_access_key` and `aws_secret_key` is a credentials pair that provides access to AWS for the deployer; You can use the `aws_profile` instead. In that case, AWS CLI profile will be used. Also, if none of the access key and profile provided, the `default` AWS profile will be used. The `aws_region` should be left at `us-east-1` as some of the other regions fail for different reasons;
- `backend` variable defines whether deployer should keep state files remote or locally. Set `backend` variable to `true` if you want to save state file to the remote S3 bucket;
- `upload_config_to_s3` - set to `true` if you want to upload config `all.yml` file to the S3 bucket automatically after the deployment. Will not work if `backend` is set to false;
- `upload_debug_info_to_s3` - set to `true` if you want to upload full log output to the S3 bucket automatically after the deployment. Will not work if `backend` is set to false. *IMPORTANT*: Locally logs are stored at `log.txt` which is not cleaned automatically. Please, do not forget to clean it manually or using the `clean.yml` playbook;
- `bucket` represents a globally unique name of the bucket where your configs and state will be stored. It will be created automatically during the deployment;

*Note*: a chain name shouldn't be more than 5 characters. Otherwise, it causing the error, because the aws load balancer name should not be greater than 32 characters.

## Infrastructure related variables
- `terraform_location` is an address of the Terraform binary on the builder;
- `dynamodb_table` represents the name of  table that will be used for Terraform state lock management;
- If `ec2_ssh_key_content` variable is not empty, Terraform will try to create EC2 SSH key with the `ec2_ssh_key_name` name. Otherwise, the existing key with `ec2_ssh_key_name` name will be used;
- `instance_type` defines a size of the Blockscout instance that will be launched during the deployment process;
- `vpc_cidr`, `public_subnet_cidr`, `db_subnet_cidr` represents the network configuration for the deployment. Usually you want to leave it as is. However, if you want to modify it, please, expect that `db_subnet_cidr` represents not a single network, but a group of networks started with defined CIDR block increased by 8 bits. 
  Example:
  Number of networks: 2
  `db_subnet_cidr`: "10.0.1.0/16"
  Real networks: 10.0.1.0/24 and 10.0.2.0/24
- An internal DNS zone with`dns_zone_name` name will be created to take care of BlockScout internal communications;
- The `root_block_size` is the amount of storage on your EC2 instance. This value can be adjusted by how frequently logs are rotated. Logs are located in `/opt/app/logs` of your EC2 instance;

- Each of the `db_*` variables configures the database for each chain. Each chain will have the separate RDS instance;
- `instance_type` represent the size of the EC2 instance to be deployed in production;
- `use_placement_group` determines whether or not to launch BlockScout in a placement group.

## Blockscout related variables

- `blockscout_repo` - a direct link to the Blockscout repo;
- `branch` - maps branch at `blockscout_repo` to each chain;
- Specify the `merge_commit` variable if you want to merge any of the specified `chains` with the commit in the other branch. Usually may be used to update production branches with the releases from master branch;
- `skip_fetch` - if this variable is set to `true` , BlockScout repo will not be cloned and the process will start from building the dependencies. Use this variable to prevent playbooks from overriding manual changes in cloned repo;
- `ps_*` variables represents a connection details to the test Postgres database. This one will not be installed automatically, so make sure `ps_*` credentials are valid before starting the deployment;

## Database Storage Required

The configuration variable `db_storage` can be used to define the amount of storage allocated to your RDS instance. The chart below shows an estimated amount of storage that is required to index individual chains. The `db_storage` can only be adjusted 1 time in a 24 hour period on AWS.

| Chain            | Storage (GiB) |
| ---------------- | ------------- |
| POA Core         | 200           |
| POA Sokol        | 400           |
| Ethereum Classic | 1000          |
| Ethereum Mainnet | 4000          |
| Kovan Testnet    | 800           |
| Ropsten Testnet  | 1500          |

# Deploying the Infrastructure

1. Ensure all the [infrastructure prerequisites](#Prerequisites-for-deploying-infrastructure) are installed and has the right version number;
2. Create the AWS access key and secret access key for user with [sufficient permissions](#AWS);
3. Create `hosts` file from `hosts.example`  (`mv hosts.example hosts`) and adjust to your needs. Each host should represent each BlockScout instance you want to deploy. Note, that each host name should belong exactly to one group. Also, as per Ansible requirements, hosts and groups names should be unique.

The simplest `hosts` file with one BlockScout instance will look like:

```ini
[group]
host
```

Where `[group]` is a group name, which will be interpreted as a `prefix` for all created resources and `host` is a name of BlockScout instance.

4. For each host merge `infrastructure.yml.example` and `all.yml.example` config template files in `host_vars` folder into single config file with the same name as in `hosts` file:

```bash
cat host_vars/infrastructure.yml.example host_vars/all.yml.example > host_vars/host.yml
```
5. For each group merge `infrastructure.yml.example` and `all.yml.example` config template files in `group_vars` folder into single config file with the same name as group name in `hosts` file:

```bash
cat group_vars/infrastructure.yml.example group_vars/all.yml.example > group_vars/group.yml
```

6. Adjust the variables at `group_vars` and `host_vars`. Note - you can move variables between host and group vars depending on if variable should be applied to the host or to the entire group. The list of the variables you can find at the [corresponding part of instruction](#Configuration);
Also, if you need to **distribute variables accross all the hosts/groups**, you can add these variables to the `group_vars/all.yml` file. Note about variable precedence => [Official Ansible Docs](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable).

7. Run `ansible-playbook deploy_infra.yml`; 

- During the deployment the ["diffs didn't match"](#error-applying-plan-diffs-didnt-match) error may occur, it will be ignored automatically. If  Ansible play recap shows 0 failed plays, then the deployment was successful despite the error.
- Optionally, you may want to check the variables the were uploaded to the [Parameter Store](https://console.aws.amazon.com/systems-manager/parameters) at AWS Console.


# Deploying BlockScout

0. (optional) This step is for mac OS users. Please skip it, if this is not your case.

To avoid the error
```
TASK [main_software : Fetch environment variables] ************************************
objc[12816]: +[__NSPlaceholderDate initialize] may have been in progress in another thread when fork() was called.
objc[12816]: +[__NSPlaceholderDate initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
```
error and crashing of Python follow the next steps:

- Open terminal: `nano .bash_profile`;
- Add the following line to the end of the file: `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES`;
- Save, exit, close terminal and re-open the terminal. Check to see that the environment variable is now set: `env`

(source: https://stackoverflow.com/questions/50168647/multiprocessing-causes-python-to-crash-and-gives-an-error-may-have-been-in-progr);

1. Ensure all the [BlockScout prerequisites](#Prerequisites-for-deploying-blockscout) are installed and has the right version number;
2. Create the AWS access key and secret access key for user with [sufficient permissions](#AWS);
3. Create `hosts` file from `hosts.example`  (`mv hosts.example hosts`) and adjust to your needs. Each host should represent each BlockScout instance you want to deploy. Note, that each host name should belong exactly to one group. Also, as per Ansible requirements, hosts and groups names should be unique.

The simplest `hosts` file with one BlockScout instance will look like:

```ini
[group]
host
```

Where `[group]` is a group name, which will be interpreted as a `prefix` for all created resources and `host` is a name of BlockScout instance.

4. For each host merge `blockscout.yml.example` and `all.yml.example` config template files in `host_vars` folder into single config file with the same name as in `hosts` file:

```bash
cat host_vars/blockscout.yml.example host_vars/all.yml.example > host_vars/host.yml
```
If you have already merged `infrastructure.yml.example` and `all.yml` while deploying the BlockScout infrastructure, you can simply add the `blockscout.yml.example` to the merged file: `cat host_vars/blockscout.yml.example >> host_vars/host.yml`
5. For each group merge `blockscout.yml.example` and `all.yml.example` config template files in `group_vars` folder into single config file with the same name as group name in `hosts` file:

```bash
cat group_vars/blockscout.yml.example group_vars/all.yml.example > group_vars/group.yml
```
If you have already merged `infrastructure.yml.example` and `all.yml` while deploying the BlockScout infrastructure, you can simply add the `blockscout.yml.example` to the merged file: `cat group_vars/blockscout.yml.example >> group_vars/host.yml`
6. Adjust the variables at `group_vars` and `host_vars`. Note - you can move variables between host and group vars depending on if variable should be applied to the host or to the entire group. The list of the variables you can find at the [corresponding part of instruction](#Configuration);
Also, if you need to **distribute variables accross all the hosts/groups**, you can add these variables to the `group_vars/all.yml` file. Note about variable precedence => [Official Ansible Docs](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable).
  
7. Run `ansible-playbook deploy_software.yml`; 
8. When the prompt appears, check that server is running and there is no visual artifacts. The server will be launched at port 4000 at the same machine where you run the Ansible playbooks. If you face any errors you can either fix it or cancel the deployment by pressing **Ctrl+C** and then pressing **A** when additionally prompted.
9. When server is ready to be deployed simply press enter and deployer will upload Blockscout to the appropriate S3.
10. Two other prompts will appear to ensure your will on updating the Parameter Store variables and deploying the BlockScout through the CodeDeploy. Both **yes** and **true** will be interpreted as the confirmation.
11. Monitor and manage your deployment at [CodeDeploy](https://console.aws.amazon.com/codesuite/codedeploy/applications) service page at AWS Console.

# Destroying Provisioned Infrastructure

First of all you have to remove autoscaling groups (ASG) deployed via CodeDeploy manually since Terraform doesn't track them and will miss them during the automatic destroy process. Once ASG is deleted you can use `ansible-playbook destroy.yml` playbook to remove the rest of generated infrastructure. Make sure to check the playbook output since in some cases it might not be able to delete everything. Check the error description for details.

**Note!** While Terraform is stateful, Ansible is stateless, so if you modify `bucket` or `dynamodb_table` variables and run `destroy.yml` or `deploy_infra.yml`  playbooks, it will not alter the current S3/Dynamo resources names, but create a new resources. Moreover, altering `bucket` variable will make Terraform to forget about existing infrastructure and, as a consequence, redeploy it. If it absolutely necessary for you to alter the S3 or DynamoDB names you can do it manually and then change the appropriate variable accordingly. 

Also note, that changing `backend` variable will force Terraform to forget about created infrastructure also, since it will start searching the current state files locally instead of remote.

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

  `chain_db_id` variable: poa

**Note 3**: make sure MultiAZ is disabled on your database.

**Note 4**: make sure that all the variables at `group_vars/all.yml` are exactly the same as at your existing DB.

## Common Errors and Questions

### S3: 403 error during provisioning
Usually appears if S3 bucket already exists. Remember, S3 bucket has globally unique name, so if you don't have it, it doesn't mean, that it doesn't exists at all. Login to your AWS console and try to create S3 bucket with the same name you specified at `bucket` variable to ensure.

### Error Applying Plan (diffs didn't match)

If you see something like the following:

```
Error: Error applying plan:

1 error(s) occurred:

* module.stack.aws_autoscaling_group.explorer: aws_autoscaling_group.explorer: diffs didn't match during apply. This is a bug with Terraform and should be reported as a GitHub Issue.

Please include the following information in your report:

    Terraform Version: 0.11.11
    Resource ID: aws_autoscaling_group.explorer
    Mismatch reason: attribute mismatch: availability_zones.1252502072
```

This is due to a bug in Terraform, however the fix is to just rerun `ansible-playbook deploy_infra.yml` again, and Terraform will pick up where it left off. This does not always happen, but this is the current workaround if you see it.

### Server doesn't start during deployment

Even if server is configured correctly, sometimes it may not bind the appropriate 4000 port due to unknown reason. If so, simply go to the appropriate nested blockscout folder, kill and rerun server. For example, you can use the following command: `pkill beam.smp && pkill node && sleep 10 && mix phx.server`.

```

```