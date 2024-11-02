resource "aws_lb" "ecs-app-lb" {
  name               = "alb-project"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg_project.id]
  subnets            = [
    aws_subnet.ecs_public_subnet1.id,
    aws_subnet.ecs_public_subnet2.id   
  ]

 tags = {
    Name = "ecs-project-vpc"
  }
  enable_deletion_protection = false
}


resource "aws_lb_target_group" "targetgrp-project" {
  name        = "alb-project-targetgroup"
  target_type = "ip"
  port        = 443
  vpc_id      = aws_vpc.ecs_vpc.id
  protocol = "HTTPS"

  tags = {
    Name = "targetgrp"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ecs-app-lb.arn
  port              =  443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgrp-project.arn
  }
}