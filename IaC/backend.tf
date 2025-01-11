terraform {
  backend "s3" {
    bucket = "terraform-state-for-demo-vpc "
    key    = "main"
    region = "us-east-1"
    dynamodb_table = "terraform-locks"
    
  }
}