######################################## MAIN ##########################################

#================ VPC =================#
module "vpc" {
  source  = "./modules/vpc"
  project = var.project
  tags    = var.tags
}

#================= External ALB =================#
module "alb" {
  source         = "./modules/alb"
  project        = var.project
  tags           = var.tags
  alb_vpc_id     = module.vpc.vpc_id
  alb_subnet_ids = module.vpc.public_subnet_ids
}

#================= Instance =================#
module "instance" {
  source    = "./modules/ec2/instance"
  project   = var.project
  tags      = var.tags
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]
  kms_key   = module.kms.key_arn
  cicd_git  = var.cicd_git
}

#================= CloudFront =================#
module "cloudfront" {
  source          = "./modules/cloudfront"
  project         = var.project
  tags            = var.tags
  cf_alb_dns_name = module.alb.lb_dns_name
}

#================= KMS =================#
module "kms" {
  source  = "./modules/kms"
  project = var.project
  tags    = var.tags
}

#================= ECR =================#
module "ecr" {
  source  = "./modules/ecr"
  project = var.project
  tags    = var.tags
  kms_key = module.kms.key_arn
}

#================= DocumentDB =================#
module "docdb" {
  source           = "./modules/database/docdb"
  project          = var.project
  tags             = var.tags
  docdb_vpc_id     = module.vpc.vpc_id
  docdb_subnet_ids = module.vpc.private_subnet_ids
  docdb_allowed_sg = [module.instance.sg_id]
  kms_key          = module.kms.key_arn
}

#================= Valkey =================#
module "valkey" {
  source           = "./modules/database/elasticache"
  project          = var.project
  tags             = var.tags
  cache_vpc_id     = module.vpc.vpc_id
  cache_subnet_ids = module.vpc.private_subnet_ids
  cache_allowed_sg = [module.instance.sg_id]
  kms_key          = module.kms.key_arn
}

#================= Secrets =================#
module "secrets" {
  source       = "./modules/secret-manager"
  project      = var.project
  tags         = var.tags
  kms_key      = module.kms.key_arn
  secret_docdb = module.docdb.docdb_credentials
  secret_cache = module.valkey.cache_credentials
}

