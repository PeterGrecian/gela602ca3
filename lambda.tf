


resource "aws_lambda_function" "function" {
  function_name = "cvterraform"
  handler       = "lambda.handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda_function.zip"

  source_code_hash = filebase64sha256("lambda_function.zip")
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


resource "null_resource" "archive_files" {
  provisioner "local-exec" {
    command = "zip lambda_function.zip deexim.py lambda.py"
  }
}
