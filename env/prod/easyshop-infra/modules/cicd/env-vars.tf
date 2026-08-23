################################# CODE BUILD ENVIRONMENT VARIABLES ################################

locals {
  env_vars = {
    web-ui = {
      S3_BUCKET_NAME  = "${var.cicd_ui_env.s3_bucket_name}"
      DISTRIBUTION_ID = "${var.cicd_ui_env.distribution_id}"
      SECRET_MANAGER  = "${var.cicd_ui_env.secret_manager}"
      REGION          = "${var.project.region}"
    },
    auth = {
      ECR_URL        = "${var.cicd_auth_env.ecr_url}"
      SERVICE        = "${var.cicd_auth_env.service}"
      CONTAINER_NAME = "${var.cicd_auth_env.container_name}"
      SECRET_MANAGER = "${var.cicd_auth_env.secret_manager}"
      REGION         = "${var.project.region}"
    },
    product = {
      ECR_URL        = "${var.cicd_product_env.ecr_url}"
      SERVICE        = "${var.cicd_product_env.service}"
      CONTAINER_NAME = "${var.cicd_product_env.container_name}"
      SECRET_MANAGER = "${var.cicd_product_env.secret_manager}"
      REGION         = "${var.project.region}"
    },
    cart = {
      ECR_URL        = "${var.cicd_cart_env.ecr_url}"
      SERVICE        = "${var.cicd_cart_env.service}"
      CONTAINER_NAME = "${var.cicd_cart_env.container_name}"
      SECRET_MANAGER = "${var.cicd_cart_env.secret_manager}"
      REGION         = "${var.project.region}"
    },
  }
}