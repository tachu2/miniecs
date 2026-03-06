variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the ECS tasks"
  type        = list(string)
}

variable "target_group_arn" {
  description = "The ARN of the ALB target group"
  type        = string
}

variable "repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the ECS task role"
  type        = string
}
