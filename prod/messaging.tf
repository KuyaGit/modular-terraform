module "sqs" {
  source         = "../modules/sqs"
  sqs_queue_name = "notification-queue"
  project        = var.project
  environment    = var.environment
}

module "sns" {
  source         = "../modules/sns"
  sns_topic_name = "notification-topic"
  sqs_queue_arn  = module.sqs.sqs_queue_arn
  sqs_queue_url  = module.sqs.sqs_queue_url
  environment    = var.environment
  project        = var.project
}


