provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "jfdonadio-tf-state"
    region = "us-east-1"
    key    = "web-portfolio-base/terraform.tfstate"
    # dynamodb_table = "jfdonadio-terraform-locks"
  }
}