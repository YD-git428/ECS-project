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


}

module "alb_module" {
  source             = "./modules/alb"
  ssl_policy         = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  lb_tag             = "alb_project"
  lb_name            = "alb-project-name"
  http_listener_tag  = "http_tag"
  targetgrp_name     = "target-group-project"
  targetgrp_tag      = "tg_project"
  https_listener_tag = "https_tag"
  subnet_ids         = [module.vpc.subnet1_id, module.vpc.subnet2_id]
  acm_cert_arn       = "arn:aws:acm:eu-west-2:418295709007:certificate/56983b89-95e7-4726-a876-0fbddd0148d0"
  sec_grp_arn        = module.vpc.security_grp_id
  vpc_id             = module.vpc.vpcid


}

module "vpc" {
  source             = "./modules/vpc"
  vpc_tag            = "vpc_project"
  igw_tag            = "igw_project"
  route_table_tag    = "route_table_tag"
  availability_zone1 = "eu-west-2a"
  availability_zone2 = "eu-west-2b"
  subnet1_tag        = "sub_1"
  subnet2_tag        = "sub_2"
  security_group_tag = "sec_grp"
}

module "route_53" {
  source          = "./modules/route53"
  domain_name     = "youcefderder.co.uk"
  lb_dns          = module.alb_module.lb_dns_name
  cluster_id      = module.ecs_module.cluster_id
  ecs_service_id  = module.ecs_module.service_id
  email           = "youder067@gmail.com"
  healthcheck_tag = "healthcheck_project"
  sns_topic_name  = "sns_project"
  alarm_name      = "my_alarm_project"
  cloudwatch_tag  = "cloudwatch_project"
}