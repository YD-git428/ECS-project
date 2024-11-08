output "lb_arn" {
  value = aws_lb.ecs-app-lb.id
}

output "targetgrp_arn" {
  value = aws_lb_target_group.targetgrp-project.arn
}

output "listner_https_id" {
  value = aws_lb_listener.front_end_https.id
}

output "listner_http_id" {
  value = aws_lb_listener.front_end_http.id
}

output "lb_dns_name" {
  value = aws_lb.ecs-app-lb.dns_name
}