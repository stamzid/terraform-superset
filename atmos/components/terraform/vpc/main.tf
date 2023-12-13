module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.1.1"

  tags                    = var.tags
  ipv4_primary_cidr_block = var.cidr_block

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.4.1"

  tags = var.tags

  availability_zones              = var.availability_zones
  ipv4_cidr_block                 = [module.vpc.vpc_cidr_block]
  igw_id                          = [module.vpc.igw_id]
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  max_subnet_count                = var.max_subnet_count
  nat_gateway_enabled             = var.nat_gateway_enabled
  nat_instance_enabled            = var.nat_instance_enabled
  nat_instance_type               = var.nat_instance_type
  subnet_type_tag_key             = var.subnet_type_tag_key
  subnet_type_tag_value_format    = var.subnet_type_tag_value_format
  public_subnets_enabled          = var.public_subnets_enabled
  ipv4_cidrs                      = var.subnets_cidr_blocks
  vpc_id                          = module.vpc.vpc_id

  context = module.this.context
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  tags         = var.tags
}

resource "aws_vpc_endpoint" "athena" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.athena"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.subnets.private_subnet_ids
  security_group_ids = [aws_security_group.athena_sg.id]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_security_group" "athena_sg" {
  name        = "${var.tenant}-${var.environment}-${var.stage}-athena-endpoint-sg"
  description = "Security group for Athena VPC endpoint"
  vpc_id      = module.vpc.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "athena_sg_rule" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [var.cidr_block]

  security_group_id = aws_security_group.athena_sg.id
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.tenant}-${var.environment}-${var.stage}-alb-sg"
  description = "Security group for ALB to allow HTTPS traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.tenant}-${var.environment}-${var.stage}-ecs-sg"
  description = "Security group for ECS services allowing traffic from ALB"
  vpc_id      = module.vpc.vpc_id

  # Allow inbound traffic from ALB on Superset port
  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow inbound traffic from ALB on Consul port
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
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

resource "aws_vpc_endpoint" "ecs" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.ecs"
  vpc_endpoint_type  = "Interface"

  subnet_ids         = module.subnets.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_sg.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs_agent" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.ecs-agent"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.subnets.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs_telemetry" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.ecs-telemetry"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.subnets.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_sg.id]
  private_dns_enabled = true
}
