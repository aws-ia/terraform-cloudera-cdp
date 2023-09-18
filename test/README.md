# Automated tests for the Cloudera CDP Terraform module

## Overview

This folder contains test cases against the Cloudera CDP Terraform module using the ex01-minimal_inputs example.
Details of the test cases are in the table below.

| Source File | Test Case Name | Description |
|-------------|----------------|-------------|
| example01_plan_test.go | TestExample01Plan | Runs a `terraform init`, `terraform plan`, and `terraform show` on the ex01-minimal_inputs example and fails the test if there are any errors. |
| example01_apply_test.go | TestExample01Apply | Runs a `terraform init` and `terraform apply` on the ex01-minimal_inputs example and fail the test if there are any errors. |

## Running automated tests

### Test configuration variables

The following environment variables are required to be set as Terraform inputs for the test cases.

| Environment Variable | Description |
|-----------------------|----------------|
| `ENV_PREFIX`          | A short prefix name to apply to all cloud and CDP resources created. |
| `AWS_REGION`          | The AWS cloud provider region. |
| `AWS_KEY_PAIR`        | Name of a pre-existing AWS keypair. |
| `DEPLOYMENT_TEMPLATE` | The network deployment pattern. Options are public, semi-private, or private. |

Additionally, environment variables can be set for authentication to the AWS account and CDP tenant. These are listed in the table below.

| Environment Variable | Description |
|-----------------------|----------------|
| **Environment Variables for authentication to CDP** | |
| `CDP_PROFILE`          | Profile for CDP credentials. _Note_ if this variable is set then the two variables below are not required. |
| `CDP_ACCESS_KEY_ID`        | Access key ID for the CDP credentials. |
| `CDP_SECRET_ACCESS_KEY` | Secret access key for the CDP credentials. |
| **Environment Variables for authentication to AWS** | |
| `AWS_PROFILE`          | Profile for AWS credentials. _Note_ if this variable is set then the two variables below are not required. |
| `AWS_ACCESS_KEY_ID`        | Access key ID for the CDP credentials. |
| `AWS_SECRET_ACCESS_KEY` | Secret access key for the CDP credentials. |

### Test Case Execution

The steps to run the test cases are as follows:

1. Install [Terraform](https://www.terraform.io/) and ensure it's on your `PATH`.
1. Install [Golang](https://golang.org/) and ensure this code is checked out into your `GOPATH`.
1. Change to the `test` directory and ensure all dependency go packages are installed.

    ```bash
    cd test
    dep ensure
   ```

1. Set the environment variables for test case input and authentication as outlined above.
1. Run the test case.

    ```bash
    # A long timeout value is used to allow CDP deployment setup and teardown to complete
    go test -v -timeout 90m -run <Test Case Name>
    ```
