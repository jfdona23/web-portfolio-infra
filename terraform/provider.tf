provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "jfdonadio-tf-state"
    region         = "us-east-1"
    # dynamodb_table = "jfdonadio-terraform-locks"
    key            = "web-portfolio/terraform.tfstate"
  }
}