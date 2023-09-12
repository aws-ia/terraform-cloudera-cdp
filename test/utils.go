package test

import (
	"os"
	"fmt"
)

func readInputFromEnvironmentVariable(env_var string) (string) {

	if os.Getenv(env_var) == "" {
		fmt.Println("Required input Environment variable: '" + env_var + "' is not set.")
		os.Exit(1)
	}
	
	return os.Getenv(env_var)
}

func setEnvironmentVariables() (map[string]string) {

	var (
		envVars     = make(map[string]string)
	)

	// Read environment variables for CDP
	CDP_PROFILE := os.Getenv("CDP_PROFILE")
	CDP_ACCESS_KEY_ID := os.Getenv("CDP_ACCESS_KEY_ID")
	CDP_SECRET_ACCESS_KEY := os.Getenv("CDP_SECRET_ACCESS_KEY")

	// Read environment variables for AWS
	AWS_PROFILE := os.Getenv("AWS_PROFILE")
	AWS_ACCESS_KEY_ID := os.Getenv("AWS_ACCESS_KEY_ID")
	AWS_SECRET_ACCESS_KEY := os.Getenv("AWS_SECRET_ACCESS_KEY")

	// Return the environment variables that are set for use through Terratest
	if CDP_PROFILE != "" { envVars["CDP_PROFILE"] = CDP_PROFILE }
	if CDP_ACCESS_KEY_ID != "" { envVars["CDP_ACCESS_KEY_ID"] = CDP_ACCESS_KEY_ID }
	if CDP_SECRET_ACCESS_KEY != "" { envVars["CDP_SECRET_ACCESS_KEY"] = CDP_SECRET_ACCESS_KEY }

	if AWS_PROFILE != "" { envVars["AWS_PROFILE"] = AWS_PROFILE }
	if AWS_ACCESS_KEY_ID != "" { envVars["AWS_ACCESS_KEY_ID"] = AWS_ACCESS_KEY_ID }
	if AWS_SECRET_ACCESS_KEY != "" { envVars["AWS_SECRET_ACCESS_KEY"] = AWS_SECRET_ACCESS_KEY }

	return envVars
}