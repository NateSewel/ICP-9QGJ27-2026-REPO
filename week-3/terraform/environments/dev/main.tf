module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  common_tags        = var.common_tags
}

module "security_groups" {
  source = "../../modules/security_groups"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  common_tags = var.common_tags
}

module "ec2" {
  source = "../../modules/ec2"

  environment        = var.environment
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.ec2_sg_id
  instance_count     = var.instance_count
  instance_type      = var.instance_type
  common_tags        = var.common_tags
  rds_endpoint       = module.rds.db_endpoint
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}

module "rds" {
  source = "../../modules/rds"

  environment       = var.environment
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.rds_sg_id
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  common_tags       = var.common_tags
}

module "elasticache" {
  source = "../../modules/elasticache"

  environment       = var.environment
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.redis_sg_id
  common_tags       = var.common_tags
}

module "sqs" {
  source = "../../modules/sqs"

  environment = var.environment
  common_tags = var.common_tags
}

module "alb" {
  source = "../../modules/alb"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  instance_ids      = module.ec2.instance_ids
  common_tags       = var.common_tags
}

module "vault" {
  source = "../../modules/vault"

  environment       = var.environment
  subnet_id         = module.vpc.private_subnet_ids[0]
  security_group_id = module.security_groups.ec2_sg_id
  common_tags       = var.common_tags
}
