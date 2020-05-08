resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = var.cluster
  task_definition = aws_ecs_task_definition.main.arn

  desired_count = var.autoscaling_range[0]

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  health_check_grace_period_seconds = 120

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = module.target_group.arn
    container_name   = "api"
    container_port   = "9292"
  }

  lifecycle {
    ignore_changes = [desired_count, capacity_provider_strategy]
  }
}

# define the iam target group along with alb rules and dns entries
module "target_group" {
  source = "git::https://gitlab.com/5stones/tf-modules//aws/lb/target-group?ref=v2.2.0"

  name     = var.name
  hostname = var.hostname
  alb      = var.alb
  zone     = var.zone
  health_check = {
    path                = "/"
    timeout             = 20
    interval            = 60
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

module "autoscaling" {
  source = "git::https://gitlab.com/5stones/tf-modules//aws/ecs/autoscaling?ref=v2.2.0"

  cluster = aws_ecs_service.main.cluster
  service = aws_ecs_service.main.name
  range   = var.autoscaling_range
}
