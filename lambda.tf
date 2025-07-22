
resource "aws_lambda_function" "function" {
  function_name    = "gela602ca3"
  handler          = "lambda.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_exec.arn
  filename         = "lambda_function.zip"
  timeout          = 15   # seconds
  memory_size      = 1024 # MB
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.bucketB.bucket
    }
  }
}

resource "null_resource" "archive_files" {
  provisioner "local-exec" {
    command = "cp pil.zip lambda_function.zip; zip lambda_function.zip deexim.py lambda.py"
  }
}


resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AWSLambdaBasicExecutionRole policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "lambda_exec_policy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucketA.arn}"
      },
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucketA.arn}/*"
        }, {
        Action   = ["s3:PutObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucketB.arn}/*"
      }
    ]
  })
}


resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  principal     = "s3.amazonaws.com"
  function_name = aws_lambda_function.function.function_name
  source_arn    = aws_s3_bucket.bucketA.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucketA.id

  lambda_function {
    events        = ["s3:ObjectCreated:Put"] # "*" will trigger it twice
    filter_suffix = ".jpg"

    lambda_function_arn = aws_lambda_function.function.arn
  }

  depends_on = [aws_lambda_permission.allow_s3_trigger]
}