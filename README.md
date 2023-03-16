# terraform-cloudera-cdp

This module contains resource files and example variable definition files for creation of the pre-requisite Cloud Service Provider (CSP) resources.

## Usage

The [examples](./examples) directory has example AWS Cloud Service Provider deployments for the different network architectures referred to in the [CDP Taxonomy of network architectures Documentation](https://docs.cloudera.com/cdp-public-cloud/cloud/aws-refarch/topics/cdp-pc-aws-refarch-taxonomy.html#ariaid-title2). These are contained in the `ex01-fully_public`, `ex02-semi_private` and `ex03-fully_private` directories and use the minimum set of inputs for the module. Additionally the `ex04-all_inputs_specified` directory contains an example with all input parameters for the module.

## Deployment

### Create infrastructure

1. Clone this repository using the following commands:

```bash
git clone https://github.com/jimright/terraform-cloudera-cdp.git  
cd terraform_cdp_pre_reqs
```

2. Choose one of the deployment types in the [examples](./examples) directory and change to this directory.

```bash
cd examples/ex<deployment_type>/
```

3. Create a `terraform.tfvars` file with variable definitions to run the module. Reference the `terraform.tfvars.sample` file in each example folder to create this file.

4. Run the Terraform module for the choosen deployment type:

```bash
terraform init
terraform apply
```

Once the deployment completes, you can create CDP Data Hubs and Data Services from the CDP Management Console (https://cdp.cloudera.com/).

## Clean up the infrastructure

If you no longer need the infrastructure that’s provisioned by the Terraform module, run the following command to remove the deployment infrastructure and terminate all resources.

```bash
terraform destroy
```

## External dependencies

The module includes the option to discover the cross account Ids and to run the CDP deployment using external tools.

To utilize these options extra requirements are needed - Python 3, Ansible 2.12, the CDP CLI, the [jq utility](https://stedolan.github.io/jq/download/) and a number of support Python libraries and Ansible collections.

A summary of the install and configuration steps for these additional requirements is given below.
We recommend these steps be performed within an Python virtual environment.

```bash
# Install jq as per instructions at https://stedolan.github.io/jq/download/
# Example for MacOS using homebew shown below
brew install jq

# Install the Ansible core Python package
pip install ansible-core==2.12.10 jmespath==1.0.1

# Install cdpy, a Pythonic wrapper for Cloudera CDP CLI. This in turn installs the CDP CLI.
pip install git+https://github.com/cloudera-labs/cdpy@main#egg=cdpy

# Install the cloudera.cloud Ansible Collection
ansible-galaxy collection install git+https://github.com/cloudera-labs/cloudera.cloud.git

# Install the community.general Ansible Collection
ansible-galaxy collection install community.general:==5.5.0

# Configure cdp with CDP API access key ID and private key
cdp configure
```

NOTE - See the [CDP documentation for steps to Generate the API access key](https://docs.cloudera.com/cdp-public-cloud/cloud/cli/topics/mc-cli-generating-an-api-access-key.html) required in the `cdp configure` command above.
