# Terraform Module for CDP Prerequisites

This module automates the deployment of Cloudera Data Platform (CDP) Public Cloud on AWS Cloud. It contains resource files and example variable definition files for both the creation of the prerequisite AWS resources and CDP services.

You can read more about [CDP Public Cloud](https://docs.cloudera.com/cdp-public-cloud/cloud/overview/topics/cdp-public-cloud.html) or [Creating and managing CDP deployments](https://docs.cloudera.com/cdp-public-cloud/cloud/getting-started/topics/cdp-creating_and_managing_cdp_deployments.html#cdp_creating_and_managing_cdp_deployments) in the Cloudera documentation.

This repository provides a module that allows you to perform the following:
* Create AWS networking resources required by a CDP deployment following the [network reference architectures](https://docs.cloudera.com/cdp-public-cloud/cloud/aws-refarch/topics/cdp-pc-aws-refarch-taxonomy.html).
* Deploy CDP in an existing VPC by specifying target subnets and security groups.
* Create or import S3 buckets for CDP to store data, logs, audit and metadata.
* Define a cross-account policy and role that your CDP tenant can use to interact with your AWS Cloud account.
* Deploy the core services of CDP (environment and data lake service) and the required configuration (credential, default locations, storage access permissions).

This module also gives you the flexibility to choose between a simple reference setup and a high degree of customization. The [examples](./examples) directory has example AWS Cloud deployments for different scenarios:
* `ex01-minimal-inputs` uses the minimum set of inputs for the module. This can be used to quickly set up a reference deployment of CDP in a newly created, empty AWS account with access over the internet. This option is ideal for getting started with CDP.
* `ex02-existing-vpc` creates a VPC and subnets outside of the module and passes this as an additional input. CDP deployment then uses these network assets rather than creating new ones. This is intended as an example for bringing your existing networking infrastructure and installing CDP inside.
* `ex03-all_inputs_specified` contains an example with all input parameters for the module.

In each directory an example `terraform.tfvars.sample` values file is included to show input variable values.

## Prerequisites

To use the module provided here, you will need the following prerequisites:

* An AWS account (for an evaluation or PoC we recommend using a dedicated AWS account for CDP)
* A CDP Public Cloud account (you can sign up for a  [60-day free pilot](https://www.cloudera.com/campaign/try-cdp-public-cloud.html) )
* A recent version of Terraform software (version 0.13 or higher)

## Authors and Contributors

Battulga Purevragchaa (AWS), Nidhi Gupta (AWS), Jim Enright (Cloudera), Webster Mudge (Cloudera), Adrian Castello (Cloudera), Balazs Gaspar (Cloudera)

## Architecture

![Deployment Architecture](./images/deployment-architecture.png)

The `ex01-minimal-inputs` example implements a semi-private reference architecture of CDP. This deploys customer workloads to private subnets, but exposes CDP service endpoints, which data consumers can access over a load balancer with a public IP address. Security groups or allow-lists (IP addresses or CIDR) on Load Balancers must be used to restrict access to these public services only to corporate networks as needed. 

A detailed description of this setup is available under the Cloudera  [Public Endpoint Access Gateway](https://docs.cloudera.com/management-console/cloud/connection-to-private-subnets/topics/mc-endpoint_access_gateway.html) documentation. This setup provides a balance between security and ease of use. **For secure deployments, we recommend [private setups](https://docs.cloudera.com/cdp-public-cloud/cloud/aws-refarch/topics/cdp-pc-aws-refarch-taxonomy.html#cdp_pc_aws_architecture_taxonomy) without assigning public IP addresses / providing direct access from the internet to the subnets used by CDP.**

The various network flows in this architecture are depicted in the diagram below:

![Network traffic flows](./images/endpoint-access-gateway-network-traffic-flow.png)

The reference architecture for semi-private deployments includes following components:
* A VPC spanning multiple AWS availability zones of the selected region
* Three private subnets for FreeIPA, Data Lake and Data Hub cluster nodes (traditional EC2 instances)
* Three public subnets with a public and a private Network Load Balancer
* An Internet Gateway for egress traffic
* AWS NAT Gateways (one per subnet) 
* Two AWS security groups  [as required by CDP](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-aws/topics/mc-aws-req-security-groups.html) 
* A [cross-account role](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-aws/topics/mc-aws-req-credential.html)  and an attached cross-account policy providing access to the AWS Cloud account from your  [CDP Management Console](https://docs.cloudera.com/management-console/cloud/overview/topics/mc-management-console.html)  
* Various IAM roles, policies and instance profiles for configuring fine-grain permission for [cloud storage access](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-aws/topics/mc-idbroker-minimum-setup.html) and AWS compute services.
* An AWS S3 bucket with three default locations for storing data, table metadata, logs and audit.

## Deployment steps

### Configure local prerequisites

1. You will need to configure your AWS credentials locally so that Terraform can find them. Examples are shown in  [Build Infrastructure | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build) on how to configure the required environment variables.
2. If you have not yet configured your `~/.cdp/credentials file`, follow the steps for [Generating an API access key](https://docs.cloudera.com/cdp-public-cloud/cloud/cli/topics/mc-cli-generating-an-api-access-key.html) 
3. To install Terraform follow the official  [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) guide from Hashicorp.

### Create infrastructure

1. Clone this repository using the following commands:
```bash
git clone https://github.com/aws-ia/terraform-cloudera-cdp.git  
cd terraform-cloudera-cdp
```
2. Choose one of the deployment types in the [examples](./examples) directory and change to this directory.
```bash
cd examples/ex<deployment_type>/
```
3. Create a `terraform.tfvars` file with variable definitions to run the module. Reference the `terraform.tfvars.sample` file in each example folder to create this file (or simply rename it and change the values for the input variables).
4. Run the Terraform module for the chosen deployment type:
```bash
terraform init
terraform apply
```
5. Once the creation of the CDP environment and data lake starts, you can follow the deployment process on the CDP Management Console from your browser in ( [https://cdp.cloudera.com/](https://cdp.cloudera.com/) ). After it completes, you can add CDP  [Data Hubs and Data Services](https://docs.cloudera.com/cdp-public-cloud/cloud/overview/topics/cdp-services.html) to your newly deployed environment from the Management Console UI or using the CLI.

### Clean up the infrastructure

If you no longer need the infrastructure that’s provisioned by the Terraform module, run the following command (from the same working directory) to remove the deployment infrastructure and terminate all resources.

```bash
terraform destroy
```
