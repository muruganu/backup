resource "aws_backup_vault" "vault" {
  name = "backup_vault_container"
}

resource "aws_backup_vault_policy" "vault_policy" {
  backup_vault_name = aws_backup_vault.vault.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "default",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "backup:CopyIntoBackupVault",
        "backup:DescribeBackupVault"
      ],
      "Resource": "${aws_backup_vault.vault.arn}"
    }
  ]
}
POLICY
}