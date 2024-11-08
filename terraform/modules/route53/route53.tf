data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "www_project" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "tm"
  type    = "CNAME"
  ttl     = 200

  records = [var.lb_dns]
}




resource "aws_cloudwatch_metric_alarm" "ecs_metric_alarm" {
  alarm_name          = "alarm_project"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = aws_cloudwatch_log_metric_filter.error_metric_filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.error_metric_filter.metric_transformation[0].namespace
  period              = 120
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "This metric monitors fargate cpu utilization"
  alarm_actions       = [aws_sns_topic.sns_project.arn]

  dimensions = {
    ClusterName = var.cluster_id
    ServiceName = var.ecs_service_id
  }

  tags = {
    name = var.cloudwatch_tag
  }
}



resource "aws_sns_topic" "sns_project" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.sns_project.arn
  protocol  = "email"
  endpoint  = var.email
}

resource "aws_route53_health_check" "health_check" {
  fqdn                            = var.lb_dns
  port                            = 3000
  type                            = "HTTP"
  resource_path                   = "/"
  failure_threshold               = 5
  request_interval                = 30
  insufficient_data_health_status = "Healthy"


  tags = {
    Name = var.healthcheck_tag
  }
}
resource "aws_cloudwatch_log_group" "my_first_log_grp" {
  name              = "/aws/fargate/my-log-group1"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_metric_filter" "error_metric_filter" {
  name           = "ErrorCountFilter"
  log_group_name = aws_cloudwatch_log_group.my_first_log_grp.name
  pattern        = "ERROR"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "MyAppMetrics"
    value     = 1
  }
}
