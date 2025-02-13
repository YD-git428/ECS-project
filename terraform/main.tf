module "ecs_module" {
  source = "./modules/ecs"
  ecs_service_dependants = [
    module.alb_module.listner_https_id,
    module.alb_module.listner_http_id,
  module.alb_module.lb_arn]
  cluster_tag                     = "clust_tag"
  cluster_name                    = "My_Cluster_project"
  ecs_service_name                = "my_ecs_service"
  capacity_provider_name          = "fargate_project"
  ecs_service_tag                 = "ecs_service_tag"
  target_grp_arn                  = module.alb_module.targetgrp_arn
  subnet_ids_2                    = [module.vpc.subnet1_id, module.vpc.subnet2_id]
  securitygroup_id                = module.vpc.security_grp_id
  taskrole_name                   = "task_role_project"
  task_policy_name                = "task_policy_project"
  taskrole_policy_attachment_name = "role_policy"
  taskexec_name                   = "task_execution_role"
  task_definition_family          = "task_family_v1"
  execution_policy_name           = "execution_policy_project"
  container_name                  = "project_image_yd"
  ECR_image_arn                   = ""#Insert ECR ARN
  log_group_arn                   = ""# Insert ARN for CloudWatch metric namespace 
  ECR_ID                          = ""# Insert ECR ID - in this format <accountid>.dkr.... 
  log_group                       = "/aws/fargate/my-log-group1"
  region                          = "eu-west-2"
  health_check_grace_period       = 60
  instance_desired_count          = 1
  capacity_provider_base_number   = 1
  capacity_provider_weight_number = 100


}

module "alb_module" {
  source             = "./modules/alb"
  ssl_policy         = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  lb_tag             = "alb_project"
  lb_name            = "alb-name"
  load_balancer_type = "application"
  http_listener_tag  = "http_tag"
  targetname         = "targetname"
  targetgrp_tag      = "tg_project"
  target_type        = "ip"
  https_listener_tag = "https_tag"
  subnet_ids         = [module.vpc.subnet1_id, module.vpc.subnet2_id]
  acm_cert_arn       = "" #Insert ca certificate ARN
  sec_grp_arn        = module.vpc.security_grp_id
  vpc_id             = module.vpc.vpcid


}

module "vpc" {
  source             = "./modules/vpc"
  vpc_tag            = "vpc_project"
  igw_tag            = "igw_project"
  route_table_tag    = "route_table_tag"
  availability_zone1 = "" #Insert Availability Zone
  availability_zone2 = "" #Insert Availability Zone
  subnet1_tag        = "sub_1"
  subnet2_tag        = "sub_2"
  security_group_tag = "sec_grp"
}

module "route_53" {
  source          = "./modules/route53"
  domain_name     = "youcefderder.co.uk" #Insert Domain
  lb_dns_name     = module.alb_module.lb_dns_name
  cluster_id      = module.ecs_module.cluster_id
  ecs_service_id  = module.ecs_module.service_id
  email           = "" #Insert Email
  healthcheck_tag = "healthcheck_project"
  sns_topic_name  = "sns_project"
  alarm_name      = "my_alarm_project"
  cloudwatch_tag  = "cloudwatch_project"
  ttl             = 200
  log_group_name  = "/aws/fargate/my-log-group1"
}