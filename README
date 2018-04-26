# Usage

## Prerequisites

The bootstrap script included in this project expects the AWS CLI, jq, and Terraform to be installed and on the PATH.

On macOS, with Homebrew installed, just run: `brew install awscli jq terraform`

For other platforms, or if you don't have Homebrew installed, please see the following links:

- [jq](https://stedolan.github.io/jq/download/)
- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- [terraform](https://www.terraform.io/intro/getting-started/install.html)

## AWS

You will need to set up a new AWS account, and then login to that account using the AWS CLI (via `aws configure`).
It is critical that this account have full permissions to the following AWS resources/services:

- VPCs and associated networking resources (subnets, routing tables, etc.)
- Security Groups
- EC2
- S3
- SSM
- DynamoDB
- Route53
- RDS

These are required to provision the various AWS resources used by this project. If you are lacking permissions,
Terraform will fail when applying its plan, and you will have to make sure those permissions are provided.

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
- An ELB which exposes the app server HTTP endpoints to the world
- A security group to lock down ingress to the app servers to 80/443 + SSH
- A security group to allow the ELB to talk to the app servers
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
These files are `PREFIX`, `backend.tfvars`, `main.tfvars`, the contents of `plans`, and the Terraform state directories. If you generated
a private key for EC2 (the default), then you will also have a `*.privkey` file in your project root, you need to store this securely out of
band once created, but does not need to be in the repository.

## Defining Chains/Adding Chains

The default of this repo is to build infra for the `sokol` chain, but you may not want that, or want a different set, so you need to
create/edit `user.tfvars` and add the following configuration:

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
