# IAM role
resource "aws_iam_role" "role_restore" {
  name               = "aws-vault-restore-role"
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  ]
  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:PutLogEvents",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "ec2:StartInstances",
            "ec2:AttachVolume",
            "kms:Encrypt",
            "kms:Decrypt"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "backup:GetRecoveryPointRestoreMetadata",
            "backup:StartRestoreJob",
            "backup:DescribeRestoreJob",
            "backup:ListRestoreJobs",
            "backup:ListRecoveryPointsByResource"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "backup:DescribeBackupVault",
            "backup:PutBackupVaultNotifications",
            "backup:ListRecoveryPointsByBackupVault",
            "backup:GetBackupVaultNotifications",
            "backup:GetBackupVaultAccessPolicy"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:backup:*:${data.aws_caller_identity.current.account_id}:backup-vault:*"
        },
        {
          Action = [
            "iam:*"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:*"
          ],
          "Resource" : [
            "*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:*"
          ],
          "Resource": [
            "*"
          ]
        }
      ]
    })
  }
}

# IAM policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "backup.amazonaws.com"
      ]
    }
  }
}