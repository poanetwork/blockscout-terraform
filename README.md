# About

This repo contains Ansible playbooks designed in purpose of automation [Blockscout](https://github.com/poanetwork/blockscout) deployment builds. Currently it supports only [AWS](#AWS) as a cloud provider. Playbooks will create all necessary infrastructure along with cloud storage space required for saving configuration and state files.

## Prerequisites

Playbooks relies on Terraform under the hood, which is the stateful infrastructure-as-a-code software tool. It allows to keep a hand on your infrastructure - modify and recreate single and multiple resources depending on your needs.

| Dependency name                        | Installation method                                          |
| -------------------------------------- | ------------------------------------------------------------ |
| Ansible >= 2.6                         | [Installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) |
| Terraform 0.11                         | [Installation guide](https://learn.hashicorp.com/terraform/getting-started/install.html) |
| Python >=2.6.0                         | `apt install python`                                         |
| Python-pip                             | `apt install python-pip`                                     |
| boto & boto3 & botocore python modules | `pip install boto boto3 botocore`                            |

## AWS

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

## Configuration

The single point of configuration in this script is a `group_vars/all.yml` file. First, copy it from `group_vars/all.yml.example` template by executing`cp group_vars/all.yml.example group_vars/all.yml` command and then modify it via any text editor you want (vim example - `vim group_vars/all.yml`). Here is the example of configuration file (Scroll down for variables description):

```yaml
aws_access_key: ""
aws_secret_key: ""
backend: true
upload_config_to_s3: true
bucket: "poa-terraform-state"
dynamodb_table: "poa-terraform-lock"
ec2_ssh_key_name: "sokol-test"
ec2_ssh_key_content: ""
instance_type: "m5.xlarge"
vpc_cidr: "10.0.0.0/16"
public_subnet_cidr: "10.0.0.0/24"
db_subnet_cidr: "10.0.1.0/24"
dns_zone_name: "poa.internal"
prefix: "sokol"
db_id: "poa"
db_name: "poa"
db_username: "username"
db_password: "qwerty12345"
db_instance_class: "db.m4.xlarge"
db_storage: "120"
db_storage_type: "gp2"
use_ssl: "false"
alb_ssl_policy: "ELBSecurityPolicy-2016-08"
alb_certificate_arn: "arn:aws:acm:us-east-1:290379793816:certificate/6d1bab74-fb46-4244-aab2-832bf519ab24"
root_block_size: 120
pool_size: 30
secret_key_base: "TPGMvGK0iIwlXBQuQDA5KRqk77VETbEBlG4gAWeb93TvBsYAjvoAvdODMd6ZeguPwf2YTRY3n7uvxXzQP4WayQ=="
new_relic_app_name: ""
new_relic_license_key: ""
networks: >
  chains = {
    "mychain" = "url/to/endpoint"
  }
  chain_trace_endpoint = {
    "mychain" = "url/to/debug/endpoint/or/the/main/chain/endpoint"
  }
  chain_ws_endpoint = {
    "mychain" = "url/to/websocket/endpoint"
  }
  chain_jsonrpc_variant = {
    "mychain" = "parity"
  }
  chain_logo = {
    "mychain" = "url/to/logo"
  }
  chain_coin = {
    "mychain" = "coin"
  }
  chain_network = {
    "mychain" = "network name"
  }
  chain_subnetwork = {
    "mychain" = "subnetwork name"
  }
  chain_network_path = {
    "mychain" = "path/to/root"
  }
  chain_network_icon = {
    "mychain" = "_test_network_icon.html"
  }
```

- `aws_access_key` and `aws_secret_key` is a credentials pair that provides access to AWS for the deployer;
- `backend` variable defines whether Terraform should keep state files remote or locally. Set `backend` variable to `true` if you want to save state file to the remote S3 bucket;
- `upload_config_to_s3` - set to `true` if you want to upload config`all.yml` file to the S3 bucket automatically during deployment. Will not work if `backend` is set to false;
- `bucket` and `dynamodb_table` represents the name of AWS resources that will be used for Terraform state management;
- If `ec2_ssh_key_content` variable is not empty, Terraform will try to create EC2 SSH key with the `ec2_ssh_key_name` name. Otherwise, the existing key with `ec2_ssh_key_name` name will be used;
- `instance_type` defines a size of the Blockscout instance that will be launched during the deployment process;
- `vpc_cidr`, `public_subnet_cidr`, `db_subnet_cidr` represents the network configuration for the deployment. Usually you want to leave it as is. However, if you want to modify it, please, expect that `db_subnet_cidr` represents not a single network, but a group of networks united with one CIDR block that will be divided during the deployment. For details, see [subnets.tf](https://github.com/ArseniiPetrovich/blockscout-terraform/blob/master/roles/main_infra/files/subnets.tf#L35) for details;
- An internal DNS zone with`dns_zone_name` name will be created to take care of BlockScout internal communications;
- `prefix` - is a unique tag to use for provisioned resources (5 alphanumeric chars or less);
- `db_id` and `db_name` identifies your database among others. The `db_username` and `db_password` can be a changed to any alphanumeric value. The `db_instance_class`,`db_storage` and `db_storage_type` are not required but are defaulted to `db.m4.large` , `120GB` and `gp2` respectively;
- The name of a IAM key pair to use for EC2 instances, if you provide a name which
  already exists it will be used, otherwise it will be generated for you;

* If `use_ssl` is set to `false`, SSL will be forced on Blockscout. To configure SSL, use `alb_ssl_policy` and `alb_certificate_arn` variables;

- The region should be left at `us-east-1` as some of the other regions fail for different reasons;
- The `root_block_size` is the amount of storage on your EC2 instance. This value can be adjusted by how frequently logs are rotated. Logs are located in `/opt/app/logs` of your EC2 instance;
- The `pool_size` defines the number of connections allowed by the RDS instance;
- `secret_key_base` is a random password used for BlockScout internally. It is highly recommended to gernerate your own `secret_key_base` before the deployment. For instance, you can do it via `openssl rand -base64 64 | tr -d '\n'` command;
- `new_relic_app_name` and  `new_relic_license_key` should usually stay empty unless you want and know how to configure New Relic integration;
- Chain configuration is made via `networks ` variable. It is Ansible multiline variable that nests Terraform configuration based on HCL syntax. For details of chain configuration see the [appropriate section](#Chain-Configuration) of this ReadMe. For example, see the `group_vars/all.yml.example` file.

## Chain Configuration

- `chains` - maps chains to the URLs of HTTP RPC endpoints, an ordinary blockchain node can be used;
- `chain_trace_endpoint` - maps chains to the URLs of HTTP RPC endpoints, which represents a node where state pruning is disabled (archive node) and tracing is enabled. If you don't have a trace endpoint, you can simply copy values from `chains` variable;
- `chain_ws_endpoint` - maps chains to the URLs of HTTP RPCs that supports websockets. This is required to get the real-time updates. Can be the same as `chains` if websocket is enabled there (but make sure to use`ws(s)` instead of `htpp(s)` protocol);
- `chain_jsonrpc_variant` - a client used to connect to the network. Can be `parity`, `geth`, etc;
- `chain_logo` - maps chains to the it logos. Place your own logo at `apps/block_scout_web/assets/static/images` and specify a relative path at `chain_logo` variable;
- `chain_coin` - a name of the coin used in each particular chain;
- `chain_network` - usually, a name of the organization keeping group of networks, but can represent a name of any logical network grouping you want;
- `chain_subnetwork` - a name of the network to be shown at BlockScout;
- `chain_network_path` - a relative URL path which will be used as an endpoint for defined chain. For example, if we will have our BlockScout at `blockscout.com` domain and place `core` network at `/poa/core`, then the resulting endpoint will be `blockscout.com/poa/core` for this network.
- `chain_network_icon` - maps the chain name to the network navigation icon at apps/block_scout_web/lib/block_scout_web/templates/icons without .eex extension

Chain configuration will be stored in the Systems Manager Parameter Store, each chain has its own set of config values. If you modify one of these values, you will need to go and terminate the instances for that chain so that they are reprovisioned with the new configuration.

You will need to make sure to import the changes into the Terraform state though, or you run the risk of getting out of sync.

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

## Deploying the Infrastructure

1. Ensure all the [prerequisites](#Prerequisites) are installed and has the right version number;
2. Create the AWS access key and secret access key for user with [sufficient permissions](#AWS);
3. Set the configuration file as described at the [corresponding part of instruction](#Configuration);
4. Run `ansible-playbook deploy.yml`;
5. Save the output and proceed to the [next part of instruction](#Deploying-Blockscout).

## Deploying BlockScout

Once infrastructure is deployed, read [this](https://forum.poa.network/t/deploying-blockscout-with-terraform/1952#preparing-blockscout) and [this](https://forum.poa.network/t/deploying-blockscout-with-terraform/1952#deploying-blockscout) parts of Blockscout deployment instruction along with the infrastructure deployment output to continue Blockscout deployment.

## Destroying Provisioned Infrastructure

You can use `ansible-playbook destroy.yml` file to remove any generated infrastructure. It is
important to note though that if you run this script on partially generated infrastructure, or if an error occurs during the destroy process, that you may need to manually check for, and remove, any resources that were not able to be deleted for you. 

**Note!** While Terraform is stateful, Ansible is stateless, so if you modify `bucket` or `dynamodb_table` variables and run `destroy.yml` or `deploy.yml`  playbooks, it will not alter the current S3/Dynamo resources names, but create a new resources. Moreover, altering `bucket` variable will make Terraform to forget about existing infrastructure and, as a consequence, redeploy it. If it absolutely necessary for you to alter the S3 or DynamoDB names you can do it manually and then change the appropriate variable accordingly. 

Also note, that changing `backend` variable will force Terraform to forget about created infrastructure also, since it will start searching the current state files locally instead of remote.

## Migrating deployer to another machine

You can easily manipulate your deployment from any machine with sufficient prerequisites. If  `upload_config_to_s3` variable is set to true, the deployer will automatically upload your `all.yml` file to the s3 bucket, so you can easily download it to any other machine. Simply download this file to your `group_vars` folder and your new deployer will pick up the current deployment instead of creating a new one.

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

    Terraform Version: 0.11.7
    Resource ID: aws_autoscaling_group.explorer
    Mismatch reason: attribute mismatch: availability_zones.1252502072
```

This is due to a bug in Terraform, however the fix is to just rerun `ansible-playbook deploy.yml` again, and Terraform will pick up where it left off. This does not always happen, but this is the current workaround if you see it.