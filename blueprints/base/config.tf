terraform {
  backend "s3" {
    bucket         = "sleepless-iac-state-storage"
    key            = "base/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "SleeplessIacStateLock"
  }
}
