terraform {
  backend "s3" {
    bucket         = "terraform-state-for-demo-vpc"
    key            = "tf/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}