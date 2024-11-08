output "vpcid" {
  value = aws_vpc.ecs_vpc.id
}

output "igw_arn" {
  value = aws_internet_gateway.ecs-igw.id
}

output "subnet1_id" {
  value = aws_subnet.ecs_public_subnet1.id
}

output "subnet2_id" {
  value = aws_subnet.ecs_public_subnet2.id
}

output "route_tableid" {
  value = aws_route_table.ecs_route_table_pub.id
}

output "security_grp_id" {
  value = aws_security_group.ecs_sg_project.id
}