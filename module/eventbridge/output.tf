output "event-bridge-arn" {
  value = aws_cloudwatch_event_rule.vault-restore.arn
}