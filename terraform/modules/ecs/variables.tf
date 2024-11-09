variable "cluster_name" {
  type = string
}

variable "capacity_provider_name" {
  type = string
}

variable "cluster_tag" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "ecs_service_tag" {
  type = string
}

variable "ecs_service_dependants" {
  type = list(string)
}

variable "target_grp_arn" {
  type = string
}

variable "subnet_ids_2" {
  type = list(string)
}

variable "securitygroup_id" {
  type = string
}

variable "taskrole_name" {
  type = string
}

variable "task_policy_name" {
  type = string
}

variable "taskrole_policy_attachment_name" {
  type = string
}

variable "taskexec_name" {
  type = string
}

variable "task_definition_family" {
  type = string
}

variable "execution_policy_name" {
  type = string
}