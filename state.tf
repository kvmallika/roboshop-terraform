terraform {
  backend "s3" {
    bucket = "roboshop-vemdevops "
    key    = "roboshop/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
