terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.1"
}

provider "aws" {
  region  = "us-west-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-018d291ca9ffc002f"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}

