resource "aws_ecs_task_definition" "main" {
  family = var.name

  container_definitions = <<CONTAINERS
[
  {
    "name": "api",
    "image": "${var.docker_repo}:${var.docker_tag}",
    "cpu": 256,
    "memory": 1536,
    "memoryReservation": 768,
    "essential": true,
    "portMappings": [
        {
            "containerPort": 9292,
            "protocol": "tcp"
        }
    ],
    "logConfiguration": ${var.logConfiguration}
  }
]
CONTAINERS
}
