data "external" "git_info" {
  program = ["bash", "./gitinfo.bash"]
}

locals {
  tags = {
    CreatedBy = "Terraform"
    GitInfo   = data.external.git_info.result["gitinfo"]
  }
}