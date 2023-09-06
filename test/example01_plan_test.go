package test

import (
	"testing"
	"path/filepath"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestExample01Plan(t *testing.T) {

	// Create complex variable for ingress input varaible
	ingress_extra_cidrs_and_ports := map[string]interface{}{
		"cidrs": []string{"0.0.0.0/0"},
		"ports": []int{443, 22},
	}

	// Read other inputs from environment variables
	env_prefix := readInputFromEnvironmentVariable("ENV_PREFIX") // name prefix for cloud and CDP resources
	aws_region := readInputFromEnvironmentVariable("AWS_REGION") // Cloud Provider region
	aws_key_pair := readInputFromEnvironmentVariable("AWS_KEY_PAIR") // name of a pre-existing AWS keypair
	deployment_template := readInputFromEnvironmentVariable("DEPLOYMENT_TEMPLATE") // the deployment pattern Options are public, semi-private or private

	// Read environment variables for Cloud Provider and CDP authentication
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
			"env_prefix": env_prefix, 
			"aws_region": aws_region, 
			"aws_key_pair": aws_key_pair, 

			// # ------- CDP Environment Deployment -------
			"deployment_template": deployment_template, 

			// # ------- Network Settings -------
			// # any additional CIDRs to add the AWS Security Groups
			"ingress_extra_cidrs_and_ports": ingress_extra_cidrs_and_ports,
		},

		// Environment variables to set when running Terraform
		EnvVars: envVars,

		// Configure a plan file path so we can introspect the plan and make assertions about it.
		PlanFilePath: planFilePath,
	}

	// Run `terraform init`, `terraform plan`, and `terraform show` and fail the test if there are any errors
	terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	
	// TODO: Verification
	
}
