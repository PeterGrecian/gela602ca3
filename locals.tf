data "external" "git_info" {
  program = ["bash", "./utils-terraform/gitinfo.bash"]
}

locals {
  tags = {
    CreatedBy = "Terraform"
    GitInfo   = data.external.git_info.result["gitinfo"]
  }
}

data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
  user_arn   = data.aws_caller_identity.current.arn
}