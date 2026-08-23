############################# TERRAFORM VARIABLES ############################

#=============== Project ================#
project = {
  name       = "easyshops"
  env        = "dev"
  region     = "ap-southeast-1"
  account_id = "680993828488"
  domain     = "jayce-lab.works"
  admin_user = "jayce-lab"
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "Jayce"
}

cicd_git = {
  org    = "jayce-lab"
  branch = "dev"
  repos = {
    web-ui  = "easyshop-web-ui"
    auth    = "easyshop-auth"
    product = "easyshop-product"
    cart    = "easyshop-cart"
  }
}