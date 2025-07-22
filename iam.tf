
# Create IAM User
resource "aws_iam_user" "userA" {
  name = "A"
}


resource "aws_iam_policy" "bucket_a_policy" {
  name        = "BucketAReadWritePolicy"
  description = "Policy to allow read/write access to Bucket A"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.bucketA.arn}/*",
          aws_s3_bucket.bucketA.arn
        ]
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "attach_bucket_a_policy" {
  name       = "AttachBucketAPolicy"
  users      = [aws_iam_user.userA.name]
  policy_arn = aws_iam_policy.bucket_a_policy.arn
}


#-------------------------------------------------------------


resource "aws_iam_user" "userB" {
  name = "B"
}


resource "aws_iam_policy" "bucket_b_policy" {
  name        = "BucketBReadWritePolicy"
  description = "Policy to allow read access to Bucket B"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.bucketB.arn}/*",
          aws_s3_bucket.bucketB.arn
        ]
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "attach_bucket_b_policy" {
  name       = "AttachBucketBPolicy"
  users      = [aws_iam_user.userB.name]
  policy_arn = aws_iam_policy.bucket_b_policy.arn
}
