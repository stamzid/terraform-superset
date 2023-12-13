data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "s3/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "vpc/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "iam/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "network/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "athena" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "athena/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "ecr/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

locals {
  superset_image = data.terraform_remote_state.ecr.outputs.service_repository_urls["superset"]
  superset_log_group_name = "/ecs/superset"
}

resource "aws_ecs_cluster" "superset_cluster" {
  name = "${var.tenant}-${var.environment}-${var.stage}-superset-cluster"
}

resource "aws_cloudwatch_log_group" "superset" {
  name = local.superset_log_group_name

  tags = {
    Environment = "${var.stage}"
    Application = "superset"
  }
}

resource "aws_ecs_task_definition" "consul" {
  family                   = "consul"
  network_mode             = "awsvpc"
  execution_role_arn       = data.terraform_remote_state.iam.outputs.ecs_execution_role_arn
  task_role_arn            = data.terraform_remote_state.iam.outputs.ecs_task_role_arn
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name          = "consul"
    image         = "hashicorp/consul:${var.consul_version}"
    essential     = true
    portMappings = [{
      containerPort = 8500
      hostPort      = 8500
    }]
  }])
}

resource "aws_ecs_task_definition" "superset" {
  family                   = "superset"
  network_mode             = "awsvpc"
  execution_role_arn       = data.terraform_remote_state.iam.outputs.ecs_execution_role_arn
  task_role_arn            = data.terraform_remote_state.iam.outputs.athena_role_arn
  cpu                      = "1024"
  memory                   = "2048"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name          = "superset"
    image         = local.superset_image
    essential     = true
    environment = [
      { name = "ADMIN_USERNAME", value = var.admin_username },
      { name = "ADMIN_PASSWORD", value = var.admin_password },
      { name = "SUPERSET_SECRET_KEY", value = var.superset_secret_key },
    ]
    portMappings  = [{
      containerPort = 8088
      hostPort      = 8088
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = local.superset_log_group_name
        awslogs-region        = "${var.region}"
        awslogs-stream-prefix = "superset/"
      }
    }
  }])
}

resource "aws_ecs_service" "superset_service" {
  name            = "superset-service"
  cluster         = aws_ecs_cluster.superset_cluster.id
  task_definition = aws_ecs_task_definition.superset.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_groups = [data.terraform_remote_state.vpc.outputs.ecs_sg_id]
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.network.outputs.superset_tg_arn
    container_name   = "superset"
    container_port   = 8088
  }

  desired_count = 1
}

resource "aws_ecs_service" "consul_service" {
  name            = "consul-service"
  cluster         = aws_ecs_cluster.superset_cluster.id
  task_definition = aws_ecs_task_definition.consul.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_groups = [data.terraform_remote_state.vpc.outputs.ecs_sg_id]
  }
  desired_count = 1
}
