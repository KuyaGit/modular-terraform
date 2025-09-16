terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
  }

  backend "http" {
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "ap-southeast-1"

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
      Terraform   = "true"
    }
  }
}
