# Subscribe SQS to SNS
resource "aws_sns_topic_subscription" "sns_to_sqs" {
  count      = var.enable_sns && var.enable_sqs && var.subscribe_sqs_to_sns ? 1 : 0
  topic_arn  = aws_sns_topic.this[0].arn
  protocol   = "sqs"
  endpoint   = aws_sqs_queue.this[0].arn

  depends_on = [aws_sqs_queue.this, aws_sns_topic.this]
}

# Grant SNS permission to send messages to SQS
resource "aws_sqs_queue_policy" "sns_policy" {
  count     = var.enable_sns && var.enable_sqs && var.subscribe_sqs_to_sns ? 1 : 0
  queue_url = aws_sqs_queue.this[0].url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.this[0].arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.this[0].arn
          }
        }
      }
    ]
  })
}
