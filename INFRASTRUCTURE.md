# Deploying the Infrastructure

1. Ensure all the [infrastructure prerequisites](#Prerequisites-for-deploying-infrastructure) are installed and has the right version number;
2. Create the AWS access key and secret access key for user with [sufficient permissions](#aws-permissions);
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

6. Adjust the variables at `group_vars` and `host_vars`. Note - you can move variables between host and group vars depending on if variable should be applied to the host or to the entire group. The list of the variables you can find at the [corresponding part of instruction](#Prerequisites);
Also, if you need to **distribute variables accross all the hosts/groups**, you can add these variables to the `group_vars/all.yml` file. Note about variable precedence => [Official Ansible Docs](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable).

7. Run `ansible-playbook deploy_infra.yml`; 

Optionally, you may want to check the variables the were uploaded to the [Parameter Store](https://console.aws.amazon.com/systems-manager/parameters) at AWS Console.

# Prerequisites

Playbooks relies on Terraform under the hood, which is the stateful infrastructure-as-a-code software tool. It allows to keep a hand on your infrastructure - modify and recreate single and multiple resources depending on your needs.

The deployment process goes in two stages. First, Ansible creates S3 bucket and DynamoDB table that are required for Terraform state management. It is required to ensure that Terraform state is stored in a centralized location, so that multiple people can use Terraform on the same infra without stepping on each others toes. Terraform prevents this from happening by holding locks (via DynamoDB) against the state data (stored in S3). 

## Software
This version of playbooks supports the multi-hosts deployment, which means that infrastructure can be built on remote machines. As such, you will need to install the Ansible on a jumpbox (controller) and all the prerequisites described below, on runners.

| Dependency name                        | Installation method                                          |
| -------------------------------------- | ------------------------------------------------------------ |
| Terraform >=0.12                       | [Installation guide](https://learn.hashicorp.com/terraform/getting-started/install.html) |
| Python >=2.6.0                         | `apt install python`                                         |
| Python-pip                             | `apt install python-pip`                                     |
| boto & boto3 & botocore python modules | `pip install boto boto3 botocore`                            |
| AWS CLI                                | `pip install awscli`                                         |

## AWS permissions

During deployment you will have to provide credentials to your AWS account. Deployment process requires a wide set of permissions to do the job, so it would work best of all if you specify the administrator account credentials. 

However, if you want to restrict the permissions as much possible, here is the list of resources which are created during the deployment process:

- An S3 bucket to keep Terraform state files;
- DynamoDB table to manage Terraform state files leases;
- An SSH keypair (or you can choose to use one which was already created), this is used with any EC2 hosts;
- A VPC containing all of the resources provisioned;
- A public subnet for the app servers, and a private subnet for the database;
- PostgreSQL Aurora cluster DB;
- An internet gateway to provide internet access for the VPC;
- An ALB which exposes the app server HTTPS endpoints to the world;
- A security group to lock down ingress to the app servers to 80/443 + SSH;
- A security group to allow the ALB to talk to the app servers;
- A security group to allow the app servers access to the database;
- An internal DNS zone;
- A DNS records for the database;
- A number of autoscaling groups and launch configurations for each chain and each type of server (WEB, API, regular);
- A CodeDeploy application and deployment groups targeting the corresponding autoscaling groups.

Each configured chain will receive its own ASG (autoscaling group) and deployment group, when application updates are pushed to CodeDeploy, all autoscaling groups will deploy the new version using a blue/green strategy. Currently, there is only one EC2 host to run, and the ASG is configured to allow scaling up, but no triggers are set up to actually perform the scaling yet. This is something that may come in the future.

# Configuration

There are three groups of variables required to build BlockScout. Furst is required to create infrastructure, second is required to build BlockScout instances and the third is the one that is required both for infra and BS itself.
For your convenience we have divided variable templates into three files accordingly - `infrastructure.yml.example`, `blockscout.yml.example` and `all.yml.example` . Also we have divided those files to place them in `group_vars` and in `host_vars` folder, so you will not have to repeat some of the variables for each host/group. 

In order to deploy BlockScout, you will have to setup the following set of files for each instance:

```
/
| - group_vars
|   | - group.yml (combination of [blockscout+infrastructure+all].yml.example)
|   | - all.yml (optional, one for all instances)
| - host_vars
|   | - host.yml (combination of [blockscout+infrastructure+all].yml.example)
| - hosts (one for all instances)
```

## Common variables

- `ansible_host` - is an address where BlockScout will be built. If this variable is set to localhost, also set `ansible_connection` to `local` for better performance.
- `chain` variable sets the name of the network (Kovan, Core, xDAI, etc.). Will be used as part of the infrastructure resource names.
- `env_vars` represents a set of environment variables used by BlockScout. You can see the description of this variables at [BlockScout official documentation](https://poanetwork.github.io/blockscout/#/env-variables).
  - Also One can define `BULD_*` set of the variables, where asterisk stands for any environment variables. All variables defined with `BUILD_*` will override default variables while building the dev server.
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
- `instance_type` represents the size of the EC2 instance to be deployed in production;
- `use_placement_group` determines whether or not to launch BlockScout in a placement group.
- `regular_servers`, `web_servers` and `api_servers` represents a number of servers of each role to be deployed. Please, note that it is pointless to deploy `regular_servers` along with `web_servers` and `api_servers` together, as `web_servers` and `api_servers` will intercept all the requests, and no requests will be addressed to the `regular_servers`.

# Destroying Provisioned Infrastructure

1. Manually remove autoscaling groups (ASG) deployed via CodeDeploy. Terraform doesn't track them, and that will cause an error during the destroy process.
2. Ensure all the [infrastructure prerequisites](#Prerequisites-for-deploying-infrastructure) are installed and has the right version number;
3. Create the AWS access key and secret access key for user with [sufficient permissions](#aws-permissions);
4. Create `hosts` file from `hosts.example`  (`mv hosts.example hosts`) and adjust to your needs. Each host should represent each BlockScout instance you want to deploy. Note, that each host name should belong exactly to one group. Also, as per Ansible requirements, hosts and groups names should be unique.

The simplest `hosts` file with one BlockScout instance will look like:

```ini
[group]
host
```
5. Run `ansible-playbook destroy.yml` playbook to remove the rest of generated infrastructure. Make sure to check the playbook output since in some cases it might not be able to delete everything. Check the error description for details.

**Note 1**: While Terraform is stateful, Ansible is stateless, so if you modify `bucket` or `dynamodb_table` variables and run `destroy.yml` or `deploy_infra.yml`  playbooks, it will not alter the current S3/Dynamo resources names, but create a new resources. 

** Note 2**: Altering the `bucket` variable will make Terraform to forget about existing infrastructure and redeploy it. If it absolutely necessary for you to alter the S3 or DynamoDB names you can do it manually via AWS CLI or Console panel and then change the appropriate variable accordingly. 

**Note 3**: Changing `backend` variable will force Terraform to forget about created infrastructure also, since it will start searching the current state files locally instead of remote.

6. (optional) If the destroy process fails, you can use the following tags to repeat the particular steps:
- infra
- s3
- dynamo