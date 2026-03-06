terraform {
  backend "s3" {
    bucket = "miniecs-terraform-state"
    key    = "terraform.tfstate"
    region = var.region
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }

  required_version = "1.14.6"
}

provider "aws" {
  region = var.region
}

module "network" {
  source       = "./modules/network"
  project_name = var.project_name
}

module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.network.vpc_id
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

module "alb" {
  source          = "./modules/alb"
  project_name    = var.project_name
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  security_groups = [module.security.alb_sg_id]
}

module "ecs" {
  source             = "./modules/ecs"
  project_name       = var.project_name
  region             = var.region
  vpc_id             = module.network.vpc_id
  private_subnets    = module.network.private_subnets
  security_groups    = [module.security.ecs_tasks_sg_id]
  target_group_arn   = module.alb.target_group_arn
  repository_url     = module.ecr.repository_url
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
}