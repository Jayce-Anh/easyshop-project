############################# TERRAFORM VARIABLES ############################

#=============== Project ================#
project = {
  name       = "easyshops"
  env        = "prod"
  region     = "ap-southeast-1"
  account_id = "701604998432"
  domain     = "jayce-lab.works"
  admin_user = "jayce-lab"
}

tags = {
  Environment = "prod"
  ManagedBy   = "Terraform"
  Owner       = "Jayce"
}

cicd_git = {
  org    = "Jayce-lab-2k1"
  branch = "main"
  repos = {
    web-ui  = "easyshop-web-ui"
    auth    = "easyshop-auth"
    product = "easyshop-product"
    cart    = "easyshop-cart"
    infra   = "easyshop-infra"
  }
}

alarm_emails = ["email@example.com"]

services = {
  auth = {
    name         = "auth"
    port         = 4000
    health_check = "/health"
  }
  product = {
    name         = "product"
    port         = 5000
    health_check = "/health"
  }
  cart = {
    name         = "cart"
    port         = 6000
    health_check = "/health"
  }
}