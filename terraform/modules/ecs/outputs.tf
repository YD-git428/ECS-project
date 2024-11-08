
output "cluster_arn" {
  value = aws_ecs_cluster.ecs_cluster_project.arn
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.aws_task_definition.arn
}


output "service_id" {
  value = aws_ecs_service.ecsservice_project.id
}

output "cluster_id" {
  value = aws_ecs_cluster.ecs_cluster_project.id
}