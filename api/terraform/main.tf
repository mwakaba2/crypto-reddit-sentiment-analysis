terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "api_ecr" {
  name = "sentiment-analysis-api-repo"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "subnets" {
  source             = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/2.0.4"
  namespace          = "messari"
  stage              = "dev"
  name               = "sentiment-analysis-api"
  vpc_id             = data.aws_vpc.default.id
  igw_id             = [data.aws_internet_gateway.default.id]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name                = "sentiment-analysis-api-sg"
  vpc_id              = data.aws_vpc.default.id
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name            = "sentiment-analysis-api-alb"
  vpc_id          = data.aws_vpc.default.id
  subnets         = module.subnets.public_subnet_ids
  security_groups = [module.security_group.security_group_id]

  target_groups = [
    {
      name             = "sentiment-analysis-api-tg"
      backend_port     = 80
      backend_protocol = "HTTP"
      target_type      = "ip"
      vpc_id           = data.aws_vpc.default.id
      health_check = {
        path    = "/docs"
        port    = "80"
        matcher = "200-399"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

}

resource "aws_ecs_cluster" "cluster" {
  name = "sentiment-analysis-api-cluster"
}

module "container_definition" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.58.1"

  container_name  = "sentiment-analysis-api-container"
  container_image = "276071102144.dkr.ecr.us-east-1.amazonaws.com/sentiment-analysis-api-repo:latest"
  port_mappings = [
    {
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }
  ]
}

module "ecs_alb_service_task" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-alb-service-task.git?ref=tags/0.66.4"

  namespace                 = "messari"
  stage                     = "dev"
  name                      = "sentiment-analysis-api"
  container_definition_json = module.container_definition.json_map_encoded_list
  ecs_cluster_arn           = aws_ecs_cluster.cluster.arn
  launch_type               = "FARGATE"
  vpc_id                    = data.aws_vpc.default.id
  security_group_ids        = [module.security_group.security_group_id]
  subnet_ids                = module.subnets.public_subnet_ids
  assign_public_ip          = true
  task_memory               = 2048
  task_cpu                  = 1024

  health_check_grace_period_seconds = 300
  ignore_changes_task_definition    = false

  ecs_load_balancers = [
    {
      target_group_arn = module.alb.target_group_arns[0]
      elb_name         = ""
      container_name   = "sentiment-analysis-api-container"
      container_port   = 80
  }]
}
