terraform {
  backend "s3" {
    bucket         = "neweksbucket"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    profile        = "eksuser"
  }
}