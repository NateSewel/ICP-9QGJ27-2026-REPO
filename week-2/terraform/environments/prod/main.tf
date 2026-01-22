provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = var.project_name
}

module "compute" {
  source             = "../../modules/compute"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  db_private_ip      = module.database.db_private_ip
  ecr_repository_url = module.registry.repository_url
}

module "database" {
  source       = "../../modules/database"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = module.vpc.vpc_cidr
  subnet_id    = module.vpc.private_subnet_ids[0]
  app_sg_id    = module.compute.app_sg_id
}

module "registry" {
  source       = "../../modules/registry"
  project_name = var.project_name
}
