package test

import (
	"testing"
	"path/filepath"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestExample01Apply(t *testing.T) {

	// Create complex variable for ingress input varaible
	ingress_extra_cidrs_and_ports := map[string]interface{}{
		"cidrs": []string{"0.0.0.0/0"},
		"ports": []int{443, 22},
	}

	envVars := setEnvironmentVariables()

	// Make a copy of the terraform module to a temporary directory
	testCaseTmpFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/ex01-minimal_inputs")
	planFilePath := filepath.Join(testCaseTmpFolder, "plan.out")

	// Configure Terraform settings with path to Terraform code and input variables
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: testCaseTmpFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			//# ------- Global settings -------
			"env_prefix": "ex01-apply", // name prefix for cloud and CDP resources
			"aws_region": "eu-west-1", // Cloud Provider region
			"aws_key_pair": "jenright-keypair", // name of a pre-existing AWS keypair

			// # ------- CDP Environment Deployment -------
			"deployment_template": "public", // the deployment pattern Options are public, semi-private or private

			// # ------- Network Settings -------
			// # any additional CIDRs to add the AWS Security Groups
			"ingress_extra_cidrs_and_ports": ingress_extra_cidrs_and_ports,
		},

		// Environment variables to set when running Terraform
		EnvVars: envVars,

		// Configure a plan file path so we can introspect the plan and make assertions about it.
		PlanFilePath: planFilePath,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)
	
	// Run `terraform init`, `terraform plan`, and `terraform show` and fail the test if there are any errors
	terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// TODO: Verification
	
}
