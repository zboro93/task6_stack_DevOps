backend "s3" {
  bucket         = "zboro93-tfstate-bucket"
  key            = "envs/dev/terraform.tfstate"
  region         = "eu-central-1"
  dynamodb_table = "zboro93-terraform-locks"
  encrypt        = true
}
