resource "aws_s3_bucket" "bucketA" {
  bucket = "gela602ca3-bucket-a"
}

resource "aws_s3_bucket" "bucketB" {
  bucket = "gela602ca3-bucket-b"
}

output "bucketA_name" {
  value = aws_s3_bucket.bucketA.id
}

output "bucketB_name" {
  value = aws_s3_bucket.bucketB.id
}