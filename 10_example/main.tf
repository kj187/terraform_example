terraform {
  backend "s3" {
    bucket = "terraform.test.aoe.cloud"
    region = "eu-central-1"
    profile = "aoe-play"
  }
}

provider "aws" {
  profile = "aoe-play"
  region = "eu-central-1"
}

variable "account" {}
variable "stage" {}

resource "null_resource" "hello_world" {
  provisioner "local-exec" {
    command = "echo \"Account:${var.account}, Stage: ${var.stage}\""
  }
}