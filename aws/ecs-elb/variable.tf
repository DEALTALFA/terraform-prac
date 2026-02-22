variable "ecs_cluster_name" {
  default = "demo-ecs-cluster"
  type    = string
}
variable "container_image" {
  default = "docker.io/dealtalfa/python-ip:v1"
  type    = string
}

variable "task_definition_name" {
  default = "demo-ecs-python"
  type = string
}