# About

This repo contains scripts designed to automate [Blockscout](https://github.com/poanetwork/blockscout) deployment builds. It currently only supports [AWS](#AWS) as a cloud provider. 

Ansible Playbooks are located in the root folder. These will create all necessary infrastructure and deploy BlockScout.

Deployment details, prerequisites and other information is available in the [BlockScout docs](https://docs.blockscout.com/for-developers/ansible-deployment). 

**Sections include:**

1. [Prerequisites](https://docs.blockscout.com/for-developers/ansible-deployment/prerequisites): Infrastructure and BlockScout prerequisites
2. [AWS Permissions](https://docs.blockscout.com/for-developers/ansible-deployment/aws-permissions): AWS setup
3. [Variables](https://docs.blockscout.com/for-developers/ansible-deployment/variables): Configuration, Infra, BlockScout & Common variables
4. [Deploying the Infrastructure](https://docs.blockscout.com/for-developers/ansible-deployment/deploying-the-blockscout-infrastructure). Describes all steps to deploy the virtual hardware required for a production instance of BlockScout. *Skip this section if you already have an infrastructure and simply want to install or update your BlockScout instance.*
5. [Deploying BlockScout](https://docs.blockscout.com/for-developers/ansible-deployment/deploying-blockscout). Install or update your BlockScout.
6. [Destroying Provisioned Infrastructure](https://docs.blockscout.com/for-developers/ansible-deployment/destroying-provisioned-infrastructure). Destroy your BlockScout installation.
7. [Common Additional Tasks](https://docs.blockscout.com/for-developers/ansible-deployment/common-additional-tasks): Cleaning the cache, migrating the deployer, attaching an existing db.
8. [Common Errors and Questions](https://docs.blockscout.com/for-developers/ansible-deployment/common-errors-and-questions): Troubleshooting provisioning or server errors.


In addition, refer to the `lambda` folder which contains a set of scripts that may be useful in setting up your BlockScout infrastructure.

# License

[![License: GPL v3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
