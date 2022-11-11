resource "aws_sns_topic" "backupevent" {
  name = "backupevent"
}
resource "aws_sns_topic_subscription" "backupevent-email-target" {
  topic_arn = aws_sns_topic.backupevent.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.ddb_backup.arn
}

data "aws_iam_policy_document" "bacupsnspolicy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.backupevent.arn,
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_sns_topic_policy" "sns-topic-policy" {
  arn    = aws_sns_topic.backupevent.arn
  policy = data.aws_iam_policy_document.bacupsnspolicy.json
}