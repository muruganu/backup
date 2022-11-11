# IAM role
resource "aws_iam_role" "role_backup" {
  name               = "aws-backup-service-role"
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  ]
}

# IAM policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "ddb_lambda_policy" {
  name   = "eks_admin_policy"
  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
        {
              "Effect": "Allow",
              "Action": ["dynamodb:ListBackups"],
              "Resource": "*"
        },
        {
              "Effect": "Deny",
              "Action": ["dynamodb:DeleteBackup"],
              "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ddb_lambda_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.ddb_lambda_policy.arn
}


resource "aws_lambda_permission" "with_sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ddb_backup.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.backupevent.arn}"
}