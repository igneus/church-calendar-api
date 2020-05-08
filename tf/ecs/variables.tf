variable "name" {
  description = "The name of the service and task definition"
  default     = "church-calendar-api"
}

variable "alb" {
  description = "The name of the application load balancer, which an https rule will be added to"
}

variable "zone" {
  description = "The route53 zone for the A and AAAA entries"
}

variable "hostname" {
  description = "The hostname in the zone for the A and AAAA entries in the zone"
  default     = "church-calendar-api"
}

variable "cluster" {
  description = "The ECS cluster name"
  default     = "default"
}

variable "autoscaling_range" {
  description = "A min and max number of tasks (autoscaled by CPU usage)"
  default     = [1, 1]
}

variable "logConfiguration" {
  description = "The ECS log configuration for the task definition"
  default     = "null"
}

variable "docker_repo" {
  description = "The docker repo for the task definition"
  default     = "sourceandsummit/church-calendar-api"
}

variable "docker_tag" {
  description = "The docker tag for the task definition"
  default     = "latest"
}
