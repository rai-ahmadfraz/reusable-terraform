resource "aws_sqs_queue" "this" {
  count = var.enable_sqs ? 1 : 0
  name  = var.sqs_queue_name

  # Optional: set retention, visibility, etc.
  message_retention_seconds = 1209600 # 14 days
}
