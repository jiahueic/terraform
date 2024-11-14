terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "application-server" {
  ami           = "ami-063d43db0594b521b"
  instance_type = "t2.micro"
  tags = {
    # Name = "Amazon Linux 2 Server"
  }
}
