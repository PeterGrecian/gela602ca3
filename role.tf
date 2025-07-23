resource "aws_iam_role" "bucket_a_role" {
  name = "BucketAReadWriteRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = local.user_arn # Replace with the actual account ID of the user "peter"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "bucket_a_policy_copy" {
  name        = "BucketAReadWritePolicyCopy"
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

#
resource "aws_iam_policy_attachment" "attach_bucket_a_policy_to_role" {
  name       = "AttachBucketAReadWritePolicyToRole"
  roles      = [aws_iam_role.bucket_a_role.name]
  policy_arn = aws_iam_policy.bucket_a_policy_copy.arn
}

#
# --------------------------------------------------------------
#

resource "aws_iam_role" "bucket_b_role" {
  name = "BucketBReadRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = local.user_arn
        }
      }
    ]
  })
}


resource "aws_iam_policy" "bucket_b_policy_copy" {
  name        = "BucketBReadWritePolicyCopy"
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

#
resource "aws_iam_policy_attachment" "attach_bucket_b_policy_to_role" {
  name       = "AttachBucketBReadPolicyToRole"
  roles      = [aws_iam_role.bucket_b_role.name]
  policy_arn = aws_iam_policy.bucket_b_policy_copy.arn
}