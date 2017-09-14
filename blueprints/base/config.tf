# [sleepless] main remote state backend
terraform {
  backend "s3" {
    bucket         = "sleepless-iac-state"
    key            = "base/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "SleeplessIacStateLockSvc"
  }
}
