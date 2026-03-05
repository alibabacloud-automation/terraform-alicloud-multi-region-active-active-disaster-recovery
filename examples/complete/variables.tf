variable "ecs_instance_password" {
  description = "Password for ECS instances, must be 8-30 characters and include three of: uppercase, lowercase, numbers, special characters"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for PolarDB database, must be 8-32 characters and include uppercase, lowercase, numbers, and special characters"
  type        = string
  sensitive   = true
}
