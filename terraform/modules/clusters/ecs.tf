resource "aws_ecs_cluster" "ecs_cluster_project" {
  name = "my-cluster-project"
}

resource "aws_ecs_cluster_capacity_providers" "ecs-fargate-project" {
  cluster_name = aws_ecs_cluster.ecs_cluster_project.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}



resource "aws_ecs_service" "mongo" {
  name            = "mongodb-project"
  cluster         = aws_ecs_cluster.ecs_cluster_project.arn
  task_definition = aws_ecs_task_definition.aws_task_definition.arn
  desired_count   = 3
  iam_role        = aws_iam_policy.execution_policy.arn
  launch_type = "FARGATE"
  depends_on      = [
   aws_lb.ecs-app-lb,
   aws_subnet.ecs_public_subnet1,
   aws_subnet.ecs_public_subnet2,

  ]

    load_balancer {
    target_group_arn = aws_lb_target_group.targetgrp-project.arn
    container_name   = "latest"
    container_port   = 3000
  }
 
 network_configuration {
     subnets            = [
    aws_subnet.ecs_public_subnet1.id,
    aws_subnet.ecs_public_subnet2.id   
  ]
    security_groups  = [aws_security_group.ecs_sg_project.id]
    assign_public_ip = true
  }

}