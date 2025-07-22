provider "aws" {
  region = "eu-west-1" # Dublin
  default_tags {
    tags = local.tags
  }
}
