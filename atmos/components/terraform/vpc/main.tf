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
  from_port   = 444
  to_port     = 444
  protocol    = "tcp"
  cidr_blocks = [var.cidr_block]

  security_group_id = aws_security_group.athena_sg.id
}
