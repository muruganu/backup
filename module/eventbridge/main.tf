resource "aws_cloudwatch_event_rule" "vault-restore" {
  name        = "vault-restore-events"
  description = "vault trigger lambda"

  event_pattern = <<PATTERN
  {
  "source": [
    "aws.backup"
  ],
  "detail-type": ["Restore Job State Change"],
  "detail": {
      "status": ["COMPLETED"],
      "createdResourceArn": ["arn:aws:dynamodb:us-west-2:288866261642:table/vault-lambda-restore-test"]
    }
  }
  PATTERN
}

resource "aws_cloudwatch_event_target" "lambda-vault-restore" {
  rule      = aws_cloudwatch_event_rule.vault-restore.name
  target_id = "VaultRestore"
  arn       = var.lambda-arn
}


# Permissions for Event Bridge to trigger the Lambda
resource "aws_lambda_permission" "allow_cloudwatch_to_call_restore" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda-name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.vault-restore.arn
}
