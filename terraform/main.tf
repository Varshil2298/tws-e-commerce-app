terraform {
  backend "s3" {
    bucket         = "demo-remote-state-terraform-9289"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    # dynamodb_table = "your-lock-table"
    # encrypt        = true
  }
}
