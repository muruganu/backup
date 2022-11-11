#https://github.com/gezza-b/aws_-backup-plan-demo
#https://github.com/gezza-b/aws_-backup-plan-demo/blob/main/plan.tf

locals {
  plan_schedule_default      = "cron(10 * * * ? *)" # once every 10 minutes for testing
  cold_storage_after_default = 1
  delete_after_default       = 2
}



resource "aws_backup_plan" "backup_plan" {
  name = "backup_plan_default"
  rule {
    rule_name           = "backup_rule_default"
    target_vault_name   = aws_backup_vault.vault.name
    schedule            = local.plan_schedule_default
    start_window        = 60
    recovery_point_tags = tomap({ "plan" = "default", "time" = "${timestamp()}" })
  }
}

resource "aws_backup_selection" "selection_default" {
  iam_role_arn = aws_iam_role.role_backup.arn
  name         = "backup_selection_default"
  plan_id      = aws_backup_plan.backup_plan.id
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "true"
  }
}


resource "aws_backup_vault_notifications" "backup-sns-notification" {
  backup_vault_events = ["BACKUP_JOB_COMPLETED"]
  backup_vault_name   = aws_backup_vault.vault.name
  sns_topic_arn       = aws_sns_topic.backupevent.arn
}