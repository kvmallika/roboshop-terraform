terraform {
  backend "s3" {
    bucket = "roboshop-vemdevops"
    key    = "roboshop/terraform.tfstate"
    region = "us-east-1"
  }
}
