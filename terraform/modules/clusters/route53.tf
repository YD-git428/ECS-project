data "aws_route53_zone" "selected" {
  name         = "youcefderder.co.uk"
  private_zone = false
}

resource "aws_route53_record" "www_project" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.${data.aws_route53_zone.selected.name}"
  type    = "A"
  alias {
    name                   = aws_lb.ecs-app-lb.dns_name
    zone_id                = aws_lb.ecs-app-lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = data.aws_route53_zone.selected.name
  validation_method = "DNS"
  

  tags = {
    Name = "my_dns_cert"
  }
}
resource "aws_cloudwatch_metric_alarm" "ecs_metric_alarm" {
  alarm_name          = "alarm_project"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = aws_cloudwatch_log_metric_filter.error_metric_filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.error_metric_filter.metric_transformation[0].namespace
  period              = "120"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This metric monitors fargate cpu utilization"
  alarm_actions = [aws_sns_topic.sns_project.arn]

  dimensions = {
      ClusterName = aws_ecs_cluster.ecs_cluster_project.name
      ECSServicName = aws_ecs_service.mongo.name
  }
}



resource "aws_sns_topic" "sns_project" {
  name = "user-sns-topic"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.sns_project.arn
  protocol  = "email"
  endpoint  = "youde067@gmail.com"
}

resource "aws_route53_health_check" "health_check" {
  fqdn              = "youcefderder.co.uk"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"
  insufficient_data_health_status = "Healthy"


  tags = {
    Name = "healthcheck_route53"
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
    value     = "1"
  }
}
