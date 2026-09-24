################################### ECS TASK DEFINITION #######################################

# Auth service
resource "aws_ecs_task_definition" "auth" {
  family                   = "${var.project.env}-${var.project.name}-auth"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "${var.project.env}-${var.project.name}-auth"
      image     = "${var.ecs_ecr_urls["auth"]}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.auth.name}"
          awslogs-region        = "${var.project.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:4000/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 180
      }
      linuxParameters = {
        initProcessEnabled = true
      }
      secrets = [
        {
          name      = "DATABASE_NAME"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-auth:DATABASE_NAME::"
        },
        {
          name      = "JWT_SECRET"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-auth:JWT_SECRET::"
        },
        {
          name      = "PORT"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-auth:PORT::"
        },
        {
          name      = "NODE_ENV"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-auth:NODE_ENV::"
        },
        {
          name      = "ALLOWED_ORIGINS"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-auth:ALLOWED_ORIGINS::"
        },
        {
          name      = "DATABASE_USERNAME"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-auth:DATABASE_USERNAME::"
        },
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-auth:DATABASE_PASSWORD::"
        },
        {
          name      = "DATABASE_HOST"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-auth:DATABASE_HOST::"
        },
        {
          name      = "DATABASE_PORT"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-auth:DATABASE_PORT::"
        }
      ]
    }
  ])

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-auth"
    Module = "${path.module}"
  })
}

# Product service
resource "aws_ecs_task_definition" "product" {
  family                   = "${var.project.env}-${var.project.name}-product"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "${var.project.env}-${var.project.name}-product"
      image     = "${var.ecs_ecr_urls["product"]}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.product.name}"
          awslogs-region        = "${var.project.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:5000/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 180
      }
      linuxParameters = {
        initProcessEnabled = true
      }
      secrets = [
        {
          name      = "DATABASE_NAME"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:DATABASE_NAME::"
        },
        {
          name      = "JWT_SECRET"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:JWT_SECRET::"
        },
        {
          name      = "PORT"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:PORT::"
        },
        {
          name      = "NODE_ENV"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:NODE_ENV::"
        },
        {
          name      = "ALLOWED_ORIGINS"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:ALLOWED_ORIGINS::"
        },
        {
          name      = "DATABASE_USERNAME"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:DATABASE_USERNAME::"
        },
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:DATABASE_PASSWORD::"
        },
        {
          name      = "DATABASE_HOST"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:DATABASE_HOST::"
        },
        {
          name      = "DATABASE_PORT"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:DATABASE_PORT::"
        },
        {
          name      = "CACHE_HOST"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:CACHE_HOST::"
        },
        {
          name      = "CACHE_PORT"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-product:CACHE_PORT::"
        }
      ]
    }
  ])

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-product"
    Module = "${path.module}"
  })
}

# Cart service
resource "aws_ecs_task_definition" "cart" {
  family                   = "${var.project.env}-${var.project.name}-cart"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "${var.project.env}-${var.project.name}-cart"
      image     = "${var.ecs_ecr_urls["cart"]}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 6000
          hostPort      = 6000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.cart.name}"
          awslogs-region        = "${var.project.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:6000/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 180
      }
      linuxParameters = {
        initProcessEnabled = true
      }
      secrets = [
        {
          name      = "DATABASE_NAME"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:DATABASE_NAME::"
        },
        {
          name      = "JWT_SECRET"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:JWT_SECRET::"
        },
        {
          name      = "PORT"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:PORT::"
        },
        {
          name      = "NODE_ENV"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:NODE_ENV::"
        },
        {
          name      = "ALLOWED_ORIGINS"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:ALLOWED_ORIGINS::"
        },
        {
          name      = "DATABASE_USERNAME"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:DATABASE_USERNAME::"
        },
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:DATABASE_PASSWORD::"
        },
        {
          name      = "DATABASE_HOST"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:DATABASE_HOST::"
        },
        {
          name      = "DATABASE_PORT"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:DATABASE_PORT::"
        },
        {
          name      = "CACHE_HOST"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:CACHE_HOST::"
        },
        {
          name      = "CACHE_PORT"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:CACHE_PORT::"
        },
        {
          name      = "PRODUCT_SERVICE_URL"
          valueFrom = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_id}:secret:${var.project.env}-${var.project.name}-cart:PRODUCT_SERVICE_URL::"
        }
      ]
    }
  ])

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-cart"
    Module = "${path.module}"
  })
}
