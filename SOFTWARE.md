# Deploying BlockScout

<details><summary>0. (optional) This step is for mac OS users. Please skip it, if this is not your case.</summary>

To avoid the error
```
TASK [infrastructure : Fetch environment variables] ************************************
objc[12816]: +[__NSPlaceholderDate initialize] may have been in progress in another thread when fork() was called.
objc[12816]: +[__NSPlaceholderDate initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
```
error and crashing of Python follow the next steps:

- Open terminal: `nano .bash_profile`;
- Add the following line to the end of the file: `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES`;
- Save, exit, close terminal and re-open the terminal. Check to see that the environment variable is now set: `env`

(source: https://stackoverflow.com/questions/50168647/multiprocessing-causes-python-to-crash-and-gives-an-error-may-have-been-in-progr);
</details>

1. Ensure all the [BlockScout prerequisites](#Prerequisites) are installed and has the right version number;
2. Create the AWS access key and secret access key for user with sufficient permissions limited to creating the CodeDeploy deployments along with pushing the new version of application;
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

6. Adjust the variables at `group_vars` and `host_vars`. 

**Note 1**: You can move variables between host and group vars depending on if variable should be applied to the host or to the entire group. The list of the variables you can find at the [corresponding part of instruction](#Configuration);

**Note 2**: If you need to **distribute variables accross all the hosts/groups**, you can add these variables to the `group_vars/all.yml` file. Note about variable precedence => [Official Ansible Docs](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable).

**Note 3**: Splitting BlockScout instances into WEB and API is supported through the `regular_servers`, `web_servers` and `api_servers` variables, and not through the `env_vars` as for many other configurations.   

7. Run `ansible-playbook deploy_software.yml`; 
8. When the prompt appears, check that server is running and there is no visual artifacts. The server will be launched at random unique ports at the target remote/local machine that you have set at host_vars/<host>.yml file. If you face any errors you can either fix it or cancel the deployment by pressing **Ctrl+C** and then pressing **A** when additionally prompted.
9. When server is ready to be deployed simply press "Enter" and deployer will upload Blockscout to the appropriate S3.
10. Two other prompts will appear to ensure your will on updating the Parameter Store variables and deploying the BlockScout through the CodeDeploy. Both **yes** and **true** will be interpreted as the confirmation. Pressing "Enter" will confirm the action as well.
11. (optional) If the deployment fails, you can use the following tags to repeat the particular steps of the deployment:
- build
- update_vars
- deploy

12. Monitor and manage your deployment at [CodeDeploy](https://console.aws.amazon.com/codesuite/codedeploy/applications) service page at AWS Console.


# Prerequisites

This version of playbooks supports the multi-hosts deployment, which means that test BlockScout instances can be built on remote machines. In that case, you will need to have the Ansible, installed on jumpbox (controller) and all the prerequisites, that are described below, installed on runners.

| Dependency name                        | Installation method                                          |
| -------------------------------------- | ------------------------------------------------------------ |
| Python >=2.6.0                         | `apt install python`                                         |
| Python-pip                             | `apt install python-pip`                                     |
| boto & boto3 & botocore python modules | `pip install boto boto3 botocore`                            |
| AWS CLI                                | `pip install awscli`                                         |
| All BlockScout prerequisites           | [Check it here](https://poanetwork.github.io/blockscout/#/requirements) |

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

## Blockscout related variables

- `blockscout_repo` - a direct link to the Blockscout repo;
- `branch` - maps branch at `blockscout_repo` to each chain;
- Specify the `merge_commit` variable if you want to merge any of the specified `chains` with the commit in the other branch. Usually may be used to update production branches with the releases from master branch;
- `skip_fetch` - if this variable is set to `true` , BlockScout repo will not be cloned and the process will start from building the dependencies. Use this variable to prevent playbooks from overriding manual changes in cloned repo;
- `ps_*` variables represents a connection details to the test Postgres database. This one will not be installed automatically, so make sure `ps_*` credentials are valid before starting the deployment;