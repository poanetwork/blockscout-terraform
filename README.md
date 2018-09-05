# Usage

## Prerequisites

The bootstrap script included in this project expects the AWS CLI, jq, and Terraform to be installed and on the PATH.

On macOS, with Homebrew installed, just run: `brew install --with-default-names awscli gnu-sed jq terraform`

For other platforms, or if you don't have Homebrew installed, please see the following links:

- [jq](https://stedolan.github.io/jq/download/)
- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- [terraform](https://www.terraform.io/intro/getting-started/install.html)

You will also need the following information for the installer:

- A unique prefix to use for provisioned resources (5 alphanumeric chars or less)
- A password to use for the RDS database (at least 8 characters long)
- The name of a IAM key pair to use for EC2 instances, if you provide a name which
  already exists it will be used, otherwise it will be generated for you.

## AWS

You will need to set up a new AWS account (or subaccount), and then either login
to that account using the AWS CLI (via `aws configure`) or create a user account
that you will use for provisioning, and login to that account. The account used
requires full access to all AWS services, as a wide variety of services are used,
a mostly complete list is as follows:

- VPCs and associated networking resources (subnets, routing tables, etc.)
- Security Groups
- EC2
- S3
- SSM
- DynamoDB
- Route53
- RDS
- ElastiCache
- CodeDeploy

Given the large number of services involved, and the unpredictability of which
specific API calls will be needed during provisioning, it is recommended that
you provide a user account with full access. You do not need to keep this user
around (or enabled) except during the initial provisioning, and any subsequent
runs to update the infrastructure. How you choose to handle this user is up to you.

## Usage

Once the prerequisites are out of the way, you are ready to spin up your new infrastructure!

From the root of the project:

```
$ bin/infra help
```

This will show you the tasks and options available to you with this script.

The infra script will request any information it needs to proceed, and then call Terraform to bootstrap the necessary infrastructure
for its own state management. This state management infra is needed to ensure that Terraforms state is stored in a centralized location,
so that multiple people can use Terraform on the same infra without stepping on each others toes. Terraform prevents this from happening by
holding locks (via DynamoDB) against the state data (stored in S3). Generating the S3 bucket and DynamoDB table has to be done using local state
the first time, but once provisioned, the local state is migrated to S3, and all further invocations of `terraform` will use the state stored in S3.

The infra created, at a high level, is as follows:

- An SSH keypair (or you can choose to use one which was already created), this is used with any EC2 hosts
- A VPC containing all of the resources provisioned
- A public subnet for the app servers, and a private subnet for the database (and Redis for now)
- An internet gateway to provide internet access for the VPC
- An ALB which exposes the app server HTTPS endpoints to the world
- A security group to lock down ingress to the app servers to 80/443 + SSH
- A security group to allow the ALB to talk to the app servers
- A security group to allow the app servers access to the database
- An internal DNS zone
- A DNS record for the database
- An autoscaling group and launch configuration for each chain
- A CodeDeploy application and deployment group targeting the corresponding autoscaling groups

Each configured chain will receive its own ASG (autoscaling group) and deployment group, when application updates
are pushed to CodeDeploy, all autoscaling groups will deploy the new version using a blue/green strategy. Currently,
there is only one EC2 host to run, and the ASG is configured to allow scaling up, but no triggers are set up to actually perform the
scaling yet. This is something that may come in the future.

**IMPORTANT**: This repository's `.gitignore` prevents the storage of several files generated during provisioning, but it is important
that you keep them around in your own fork, so that subsequent runs of the `infra` script are using the same configuration and state.
These files are `backend.tfvars`, `main.tfvars`, and the Terraform state directories. If you generated
a private key for EC2 (the default), then you will also have a `*.privkey** file in your project root, you need to store this securely out of
band once created, but does not need to be in the repository.

## Migration Prompt

The installer will prompt during its initial run to ask if you want to migrate
the Terraform state to S3, this is a necessary step, and is only prompted due to
a bug in the Terraform CLI, in a future release, this shouldn't occur, but in
the meantime, you will need to answer yes to this prompt.

## Configuring Installer

The `infra` script generates config files for storing the values provided for
future runs. You can provide overrides to this configuration in
`terraform.tfvars` or any file with the `.tfvars` extension.

An example `terraform.tfvars` configuration file looks like:

```
region = "us-east-1"
bucket = "poa-terraform-state"
dynamodb_table = "poa-terraform-lock"
key_name = "sokol-test"
prefix = "sokol"
db_password = "qwerty12345"
db_instance_class = "db.m4.xlarge"
db_storage = "120"
alb_ssl_policy = "ELBSecurityPolicy-2016-08"
alb_certificate_arn = "arn:aws:acm:us-east-1:290379793816:certificate/6d1bab74-fb46-4244-aab2-832bf519ab24"
root_block_size = 120
```

- The region should be left at `us-east-1` as some of the other regions fail for different reasons.
- The `bucket` and `dynamodb_table` can be edited but should have an identical prefix.
- The `key_name` should start with the `prefix` and can only contain 5 characters and must start with a letter.
- The `db_password` can be a changed to any alphanumeric value.
- The `db_instance_class` and `db_storage` are not required but are defaulted to `db.m4.large` and `100`GB respectively.
- The `alb_ssl_policy` and `alb_certificate_arn` are required in order to force SSL usage.

## Defining Chains/Adding Chains

The default of this repo is to build infra for the `sokol` chain, but you may not want that, or want a different set, so you need to
create/edit `terraform.tfvars` or `user.auto.tfvars` and add the following configuration:

```terraform
chains = {
    "mychain" = "url/to/endpoint"
}
chain_trace_endpoints = {
    "mychain" = "url/to/debug/endpoint/or/the/main/chain/endpoint"
}
```

This will ensure that those chains are used when provisioning the infrastructure.

## Configuration

Config is stored in the Systems Manager Parameter Store, each chain has its own set of config values. If you modify one of these values,
you will need to go and terminate the instances for that chain so that they are reprovisioned with the new configuration.

You will need to make sure to import the changes into the Terraform state though, or you run the risk of getting out of sync.

## Destroying Provisioned Infrastructure

You can use `bin/infra destroy` to remove any generated infrastructure. It is
important to note though that if you run this script on partially generated
infrastructure, or if an error occurs during the destroy process, that you may
need to manually check for, and remove, any resources that were not able to be
deleted for you. You can use the `bin/infra resources` command to list all ARNs
that are tagged with the unique prefix you supplied to the installer, but not
all AWS resources support tags, and so will not be listed. Here's a list of such
resources I am aware of:

- Route53 hosted zone and records
- ElastiCache/RDS subnet groups
- CodeDeploy applications

If the `destroy` command succeeds, then everything has been removed, and you do
not have to worry about leftover resources hanging around.

## Common Errors and Questions

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

This is due to a bug in Terraform, however the fix is to just rerun `bin/infra
provision` again, and Terraform will pick up where it left off. This does not
always happen, but this is the current workaround if you see it.

### Error inspecting states in the "s3" backend

If you see the following:

```
Error inspecting states in the "s3" backend:
    NoSuchBucket: The specified bucket does not exist
    status code: 404, request id: xxxxxxxx, host id: xxxxxxxx

Prior to changing backends, Terraform inspects the source and destination
states to determine what kind of migration steps need to be taken, if any.
Terraform failed to load the states. The data in both the source and the
destination remain unmodified. Please resolve the above error and try again.
```

This is due to mismatched variables in `terraform.tfvars` and `main.tfvars` files. Update the `terraform.tfvars` file to match the `main.tfvars` file. Delete the `.terraform` and `terraform.dfstate.d` folders, run `bin/infra destroy_setup`, and restart provision by running `bin/infra provision`.


