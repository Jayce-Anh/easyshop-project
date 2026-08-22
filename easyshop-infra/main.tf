######################################## MAIN ##########################################

#================= Route53 =================#
module "hosted_zone" {
  source  = "./modules/route53"
  project = var.project
  tags    = var.tags
}

#================ VPC =================#
module "vpc" {
  source  = "./modules/vpc"
  project = var.project
  tags    = var.tags
}

#================= KMS =================#
module "kms" {
  source  = "./modules/kms"
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

#================= Bastion =================#
module "bastion" {
  source     = "./modules/ec2/bastions"
  project    = var.project
  tags       = var.tags
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.public_subnet_ids[0]
  kms_key_id = module.kms.key_arn
}

#================= CloudFront =================#
module "cloudfront" {
  source            = "./modules/cloudfront"
  project           = var.project
  tags              = var.tags
  cf_alb_dns_name   = module.alb.lb_dns_name
  cf_hosted_zone_id = module.hosted_zone.hosted_zone_id
}

#================= ECR =================#
module "ecr" {
  source     = "./modules/ecr"
  project    = var.project
  tags       = var.tags
  kms_key_id = module.kms.key_arn
}

#================= ECS =================#
module "ecs" {
  source                = "./modules/ecs"
  project               = var.project
  tags                  = var.tags
  ecs_vpc_id            = module.vpc.vpc_id
  ecs_subnets           = module.vpc.private_subnet_ids
  ecs_lb_sg_id          = module.alb.lb_sg_id
  ecs_target_group_arns = module.alb.tg_arns
  ecs_ecr_urls          = module.ecr.ecr_url
  alarm_emails          = var.alarm_emails
}

#================= DocumentDB =================#
module "docdb" {
  source           = "./modules/database/docdb"
  project          = var.project
  tags             = var.tags
  docdb_vpc_id     = module.vpc.vpc_id
  docdb_subnet_ids = module.vpc.private_subnet_ids
  docdb_allowed_sg = [module.ecs.ecs_tasks_sg_id, module.bastion.sg_id]
  kms_key_id       = module.kms.key_arn
}

#================= Valkey =================#
module "valkey" {
  source           = "./modules/database/elasticache"
  project          = var.project
  tags             = var.tags
  cache_vpc_id     = module.vpc.vpc_id
  cache_subnet_ids = module.vpc.private_subnet_ids
  cache_allowed_sg = [module.ecs.ecs_tasks_sg_id, module.bastion.sg_id]
  kms_key_id       = module.kms.key_arn
}

#================= Secrets =================#
module "secrets" {
  source       = "./modules/secret-manager"
  project      = var.project
  tags         = var.tags
  kms_key_id   = module.kms.key_arn
  secret_docdb = module.docdb.docdb_credentials
  secret_cache = module.valkey.cache_credentials
}

#================= CI/CD =================#
module "cicd" {
  source           = "./modules/cicd"
  project          = var.project
  tags             = var.tags
  cicd_git         = var.cicd_git
  cicd_ecs_cluster = module.ecs.cluster_name

  cicd_ui_env = {
    s3_bucket_name  = module.cloudfront.s3_bucket
    distribution_id = module.cloudfront.distribution_id
    secret_manager  = module.secrets.secret_id["web-ui"]
  }
  cicd_auth_env = {
    ecr_url        = module.ecr.ecr_url["auth"]
    service        = module.ecs.service_names["auth"]
    container_name = module.ecs.container_names["auth"]
    secret_manager = module.secrets.secret_id["auth"]
  }
  cicd_product_env = {
    ecr_url        = module.ecr.ecr_url["product"]
    service        = module.ecs.service_names["product"]
    container_name = module.ecs.container_names["product"]
    secret_manager = module.secrets.secret_id["product"]
  }
  cicd_cart_env = {
    ecr_url        = module.ecr.ecr_url["cart"]
    service        = module.ecs.service_names["cart"]
    container_name = module.ecs.container_names["cart"]
    secret_manager = module.secrets.secret_id["cart"]
  }
}
