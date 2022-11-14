data "archive_file" "s3_files" {
  source_dir = "${path.module}/function"
  output_path = "function.zip"
  type        = "zip"
}


resource "aws_s3_bucket" "lambda_s3_bucket" {
  bucket = "lambda-vault-restore"
  tags = {
    Name = "My Bucket"
    Environment = "Test"
  }
}

resource "aws_s3_bucket_acl" "lambda_s3_bucket_acl" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "file_upload" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id
  key    = "function.zip"
  source = data.archive_file.s3_files.output_path
  etag = filemd5(data.archive_file.s3_files.output_path)
}