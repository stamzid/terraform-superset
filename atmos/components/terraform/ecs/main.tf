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

resource "aws_ecs_cluster" "superset_cluster" {
  name = "${var.tenant}-${var.environment}-${var.stage}-superset-cluster"
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.tenant}-${var.environment}-${var.stage}-ecs-sg"
  description = "Security group for ECS services allowing traffic from ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Allow inbound traffic from ALB on Superset port
  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    security_groups = [data.terraform_remote_state.network.outputs.alb_sg_id]
  }

  # Allow inbound traffic from ALB on Consul port
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    security_groups = [data.terraform_remote_state.network.outputs.alb_sg_id]
  }

  # Typical egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tenant}-${var.environment}-${var.stage}-ecs-sg"
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
    image         = "consul:${var.consul_version}"
    essential     = true
    portMappings = [{
      containerPort = 8500
      hostPort      = 8500
    }]
  }])
}

resource "aws_ecs_task_definition" "redis" {
  family                   = "redis"
  network_mode             = "awsvpc"
  execution_role_arn       = data.terraform_remote_state.iam.outputs.ecs_execution_role_arn
  task_role_arn            = data.terraform_remote_state.iam.outputs.ecs_task_role_arn
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name          = "redis"
    image         = "redis:${var.redis_version}"
    essential     = true
    portMappings = [{
      containerPort = 6379
      hostPort      = 6379
    }]
  }])
}

resource "aws_ecs_task_definition" "superset" {
  family                   = "superset"
  network_mode             = "awsvpc"
  execution_role_arn       = data.terraform_remote_state.iam.outputs.ecs_execution_role_arn
  task_role_arn            = data.terraform_remote_state.iam.outputs.athena_role_arn
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name          = "superset"
    image         = "apache/superset:${var.superset_version}"
    essential     = true
    portMappings = [{
      containerPort = 8088
      hostPort      = 8088
    }]
  }])
}

resource "aws_ecs_service" "superset_service" {
  name            = "superset-service"
  cluster         = aws_ecs_cluster.superset_cluster.id
  task_definition = aws_ecs_task_definition.superset.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_groups = [aws_security_group.ecs_sg.id]
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
    security_groups = [aws_security_group.ecs_sg.id]
  }

  desired_count = 1
}

resource "aws_ecs_service" "redis_service" {
  name            = "redis-service"
  cluster         = aws_ecs_cluster.superset_cluster.id
  task_definition = aws_ecs_task_definition.redis.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_groups = [aws_security_group.ecs_sg.id]
  }

  desired_count = 1
}
