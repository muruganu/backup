data "aws_caller_identity" "current" {}

# Lambda Restore function and timeout in seconds 60s 5 mins
resource "aws_lambda_function" "restore-vault-lambda" {
  function_name    = "ddb-vault-restore"
  role             = aws_iam_role.role_restore.arn
  s3_bucket        = aws_s3_bucket.lambda_s3_bucket.id
  s3_key           = aws_s3_object.file_upload.key
  handler          = "restore.lambda_handler"
  source_code_hash = "${base64sha256(data.archive_file.s3_files.output_path)}"
  runtime          = "python3.9"
  timeout          = 303

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      name = "restore-lambda"
    }
  }
}

# Log group
resource "aws_cloudwatch_log_group" "lambda_restore" {
  name              = "/aws/lambda/restore"
  retention_in_days = 1
}