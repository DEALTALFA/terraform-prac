terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    version = "6.31" }
  }
}
provider "aws" {
  region = "ap-south-1"
}
resource "aws_ecs_cluster" "ecs_cluster" {
  name     = var.ecs_cluster_name
  region   = "ap-south-1"
  tags     = {}
  tags_all = {}
  configuration {
    execute_command_configuration {
      kms_key_id = null
      logging    = "DEFAULT"
    }
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}
resource "aws_ecs_task_definition" "my_ecs_task" {
  container_definitions = jsonencode([{
    environment      = []
    environmentFiles = []
    essential        = true
    image            = var.container_image
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/${var.task_definition_name}"
        awslogs-region        = "ap-south-1"
        awslogs-stream-prefix = "ecs"
      }
      secretOptions = []
    }
    memory            = 1024
    memoryReservation = 1024
    mountPoints       = []
    name              = "demo-container"
    portMappings = [{
      appProtocol   = "http"
      containerPort = 5000
      hostPort      = 5000
      name          = "demo-container-5000-http"
      protocol      = "tcp"
    }]
    systemControls = []
    ulimits        = []
    volumesFrom    = []
  }])
  cpu                      = "512"
  enable_fault_injection   = false
  execution_role_arn       = "arn:aws:iam::502016372601:role/ecsTaskExecutionRole"
  family                   = var.task_definition_name
  ipc_mode                 = null
  memory                   = "1024"
  network_mode             = "awsvpc"
  pid_mode                 = null
  region                   = "ap-south-1"
  requires_compatibilities = ["FARGATE"]
  skip_destroy             = null
  tags                     = {}
  tags_all                 = {}
  task_role_arn            = null
  track_latest             = false
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_lb_target_group" "ecs_lb_target_group" {
  deregistration_delay               = "300"
  ip_address_type                    = "ipv4"
  lambda_multi_value_headers_enabled = null
  load_balancing_algorithm_type      = "round_robin"
  load_balancing_anomaly_mitigation  = "off"
  load_balancing_cross_zone_enabled  = "use_load_balancer_configuration"
  name                               = "Flask-ECS-TG"
  port                               = 5000
  protocol                           = "HTTP"
  protocol_version                   = "HTTP1"
  proxy_protocol_v2                  = null
  region                             = "ap-south-1"
  slow_start                         = 0
  tags                               = {}
  tags_all                           = {}
  target_type                        = "ip"
  vpc_id                             = "vpc-b1f919da"
  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  stickiness {
    cookie_duration = 86400
    cookie_name     = null
    enabled         = false
    type            = "lb_cookie"
  }
  target_group_health {
    dns_failover {
      minimum_healthy_targets_count      = "1"
      minimum_healthy_targets_percentage = "off"
    }
    unhealthy_state_routing {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }
  }
}

resource "aws_lb" "ecs_lb" {
  client_keep_alive                           = 3600
  customer_owned_ipv4_pool                    = null
  desync_mitigation_mode                      = "defensive"
  dns_record_client_routing_policy            = null
  drop_invalid_header_fields                  = false
  enable_cross_zone_load_balancing            = true
  enable_deletion_protection                  = false
  enable_http2                                = true
  enable_tls_version_and_cipher_suite_headers = false
  enable_waf_fail_open                        = false
  enable_xff_client_port                      = false
  enable_zonal_shift                          = false
  idle_timeout                                = 60
  internal                                    = false
  ip_address_type                             = "ipv4"
  load_balancer_type                          = "application"
  name                                        = "Flask-ECS-LB"
  preserve_host_header                        = false
  region                                      = "ap-south-1"
  security_groups                             = ["sg-027ed1e793f0c1d22"]
  subnets                                     = ["subnet-115adb6a", "subnet-87777eef", "subnet-ebec93a7"]
  tags                                        = {}
  tags_all                                    = {}
  xff_header_processing_mode                  = "append"
  access_logs {
    bucket  = ""
    enabled = false
    prefix  = null
  }
  connection_logs {
    bucket  = ""
    enabled = false
    prefix  = null
  }
  health_check_logs {
    bucket  = ""
    enabled = false
    prefix  = null
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn                    = aws_lb.ecs_lb.arn
  port                                 = 5000
  protocol                             = "HTTP"
  region                               = aws_lb.ecs_lb.region
  routing_http_response_server_enabled = true
  tags                                 = {}
  tags_all                             = {}
  default_action {
    order            = 1
    target_group_arn = aws_lb_target_group.ecs_lb_target_group.arn
    type             = "forward"
    forward {
      stickiness {
        duration = 3600
        enabled  = false
      }
      target_group {
        arn    = aws_lb_target_group.ecs_lb_target_group.arn
        weight = 1
      }
    }
  }
}

resource "aws_security_group" "ecs_lb_sg" {
  description = "SG for load balancer"
  name                   = "ELB-SG"
  region                 = "ap-south-1"
  revoke_rules_on_delete = null
  tags                   = {}
  tags_all               = {}
  vpc_id                 = "vpc-b1f919da"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 5000
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 5000
  }]
  
}

resource "aws_security_group" "ecs_sg" {
  description = "SG for ECS(service/Tasks)"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 443
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 443
  }]
  ingress = [{
    cidr_blocks      = ["202.164.138.99/32"]
    description      = ""
    from_port        = 5000
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 5000
    }, {
    cidr_blocks      = []
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = [aws_security_group.ecs_lb_sg.id]
    self             = false
    to_port          = 0
  }]
  name                   = "ECS-CG"
  region                 = "ap-south-1"
  revoke_rules_on_delete = null
  tags                   = {}
  tags_all               = {}
  vpc_id                 = "vpc-b1f919da"
}


# import {
#   to = aws_security_group.ecs_sg
#   id = "sg-0df1c93d455b690ba"
# }