terraform {
  backend "s3" {
    bucket         = "terraform-state-for-demo-vpc"
    key            = "tf-101/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}