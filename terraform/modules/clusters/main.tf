module "project-ecs" {
  source = "../.."
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role"
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
  name        = "ecs-task-policy"
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
  name       = "task-role-attachment-to-policy"
  policy_arn = aws_iam_policy.ecs_task_policy.arn
  roles = [aws_iam_role.ecs_task_role.name]
}

resource "aws_iam_policy" "execution_policy" {
  name        = "project_policy"
  description = "My first policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
        ]
        
        Resource = "arn:aws:ecr:eu-west-2:418295709007:repository/yderder_latest"
      },
      {
        Effect = "Allow"
        Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
       Resource = [
        "arn:aws:logs:eu-west-2:418295709007:log-group:/aws/fargate/my-log-group1:*"
      ]
      }
    ]
  })
}
resource "aws_iam_role" "execution_role_ecs" {
  name = "my_execution_role"

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
  family                   = "my_project_ecs_family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "2048"
  cpu                      = "1024"
  execution_role_arn       = aws_iam_role.execution_role_ecs.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "latest",
    "image": "418295709007.dkr.ecr.eu-north-1.amazonaws.com/teambravo-yderder:latest",
    "cpu": 1024,
    "memory": 2048,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/aws/fargate/my-log-group1",
        "awslogs-region": "eu-west-2",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_DEFINITION
}


