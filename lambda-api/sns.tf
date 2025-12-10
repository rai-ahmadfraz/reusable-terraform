resource "aws_sns_topic" "this" {
  count = var.enable_sns ? 1 : 0
  name  = var.sns_topic_name
}
