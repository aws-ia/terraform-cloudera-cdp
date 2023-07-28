terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
    cdp = {
      source  = "cloudera/cdp"
      version = "0.1.3-pre"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }

  required_version = "> 1.3.0"
}
