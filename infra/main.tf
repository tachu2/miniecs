terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.35.1"
      region = "ap-northeast-1"
    }
  }

  required_version = "1.14.6"
}


