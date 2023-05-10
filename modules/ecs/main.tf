resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "api",
    "image": "${var.image_url}:develop",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
        {
          "hostPort": 3001,
          "protocol": "tcp",
          "containerPort": 3001
        }
      ]
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
  }
  volume {
    name = "uploads"

    efs_volume_configuration {
      file_system_id          = var.efs_id
      root_directory          = "/uploads"
      transit_encryption = "DISABLED"
    }
  }
}

resource "aws_lb_target_group" "this" {
  name                 = "production-api"
  port                 = 3001
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 10
  health_check {
    path = "/health"
  }
  target_type = "ip"
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = var.listerner_rule

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [var.backend_dns]
    }
  }
  
  condition {
    http_header {
      http_header_name = "X_Request_Token"
      values           = [var.auth_token]
    }
  }
}

resource "aws_ecs_service" "api" {
  name = "production-api"
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = 0
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "api"
    container_port   = 3001
  }

  network_configuration {
      subnets          = var.subnet
      security_groups  = var.security_groups
      assign_public_ip = true
  }
}