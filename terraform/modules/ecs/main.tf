

resource "aws_ecs_cluster" "ecs_cluster_project" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    name = var.cluster_tag
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs-fargate-project" {
  cluster_name = var.cluster_name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = var.capacity_provider_base_number
    weight            = var.capacity_provider_weight_number
    capacity_provider = "FARGATE"
  }
}



resource "aws_ecs_service" "ecsservice_project" {
  name                              = var.ecs_service_name
  cluster                           = aws_ecs_cluster.ecs_cluster_project.arn
  task_definition                   = aws_ecs_task_definition.aws_task_definition.arn
  desired_count                     = var.instance_desired_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = var.health_check_grace_period
  depends_on                        = [var.ecs_service_dependants]

  load_balancer {
    target_group_arn = var.target_grp_arn
    container_name   = var.container_name
    container_port   = 3000
  }

  network_configuration {
    subnets          = var.subnet_ids_2
    security_groups  = [var.securitygroup_id]
    assign_public_ip = true
  }
  tags = {
    name = var.ecs_service_tag
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = var.taskrole_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "ecs_task_policy" {
  name        = var.task_policy_name
  description = "Policy to allow ECS tasks to access objects within our s3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::terra-bucket213",
          "arn:aws:s3:::terra-bucket213/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs-attach" {
  name       = var.taskrole_policy_attachment_name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
  roles      = [aws_iam_role.ecs_task_role.name]
}

resource "aws_iam_policy" "execution_policy" {
  name        = var.execution_policy_name
  description = "Authentication to extract image layers and metadata from image stored in ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]

        Resource = var.ECR_image_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          var.log_group_arn
        ]
      }
    ]
  })
}
resource "aws_iam_role" "execution_role_ecs" {
  name = var.taskexec_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.execution_policy.arn
  role       = aws_iam_role.execution_role_ecs.name
}

resource "aws_ecs_task_definition" "aws_task_definition" {
  family                   = var.task_definition_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "3072"
  cpu                      = "1024"
  execution_role_arn       = aws_iam_role.execution_role_ecs.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "${var.container_name}",
    "image": "${var.ECR_ID}",

    "cpu": 1024,
    "memory": 3072,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000,
        "protocol": "HTTP"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${var.log_group}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_DEFINITION
}


