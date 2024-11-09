resource "aws_lb" "ecs-app-lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sec_grp_arn]
  subnets            = var.subnet_ids

  tags = {
    Name = var.lb_tag
  }
  enable_deletion_protection = false
}


resource "aws_lb_target_group" "targetgrp-project" {
  name        = var.targetname
  target_type = "ip"
  port        = 3000
  vpc_id      = var.vpc_id
  protocol    = "HTTP"

  health_check {
    path     = "/"
    protocol = "HTTP"
  }

  tags = {
    Name = var.targetgrp_tag
  }
}


resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = aws_lb.ecs-app-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = {
    name = var.http_listener_tag
  }
}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = aws_lb.ecs-app-lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.acm_cert_arn
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.targetgrp-project.arn
      }
    }
  }
  tags = {
    name = var.https_listener_tag
  }
}
