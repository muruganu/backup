data "archive_file" "lambda_ddb_backup" {
  type = "zip"
  source_dir  = "${path.module}/function"
  output_path = "ddb-function.zip"
}

resource "aws_s3_object" "mypackage4lambda" {
  bucket = var.s3_bucket_lambda

  key    = "ddb-function.zip"
  source = data.archive_file.lambda_ddb_backup.output_path

  etag = filemd5(data.archive_file.lambda_ddb_backup.output_path)
}


resource "aws_lambda_function" "ddb_backup" {
  function_name = "ddb_backup_manage"

  s3_bucket = var.s3_bucket_lambda
  s3_key    = aws_s3_object.mypackage4lambda.key

  runtime = "python3.9"
  handler = "ddback-restore.lambda_handler"

  source_code_hash = data.archive_file.lambda_ddb_backup.output_base64sha256

  role = aws_iam_role.lambda_exec_role.arn
}
