terraform {
  backend "s3" {

    bucket = "myapp-terraform-state-917318837741"

    key = "myapp/dev/terraform.tfstate"

    region = "ap-south-1"

    encrypt = true

    use_lockfile = true
  }
}