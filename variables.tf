# VPC configuration for region 1
variable "region_a_vpc_config" {
  description = "VPC configuration for primary region including VPC name and CIDR block"
  type = object({
    vpc_name   = optional(string, "vpc1")
    cidr_block = string
  })
}

# VPC configuration for region 2
variable "region_b_vpc_config" {
  description = "VPC configuration for secondary region including VPC name and CIDR block"
  type = object({
    vpc_name   = optional(string, "vpc2")
    cidr_block = string
  })
}

# Vswitch configurations for region 1
variable "region_a_vswitch_configs" {
  description = "Map of vswitch configurations for region 1, each with CIDR block and zone ID. Must contain exactly 2 vswitches."
  type = map(object({
    cidr_block = string
    zone_id    = string
  }))

  validation {
    condition     = length(var.region_a_vswitch_configs) == 2
    error_message = "region_a_vswitch_configs must contain exactly 2 vswitches for high availability."
  }
}

# Vswitch configurations for region 2
variable "region_b_vswitch_configs" {
  description = "Map of vswitch configurations for region 2, each with CIDR block and zone ID. Must contain exactly 2 vswitches."
  type = map(object({
    cidr_block = string
    zone_id    = string
  }))

  validation {
    condition     = length(var.region_b_vswitch_configs) == 2
    error_message = "region_b_vswitch_configs must contain exactly 2 vswitches for high availability."
  }
}

# Route entries for region 1 VPC
variable "region_a_route_entries" {
  description = "Map of custom route entries for region 1 VPC route table"
  type = map(object({
    destination_cidrblock = string
    nexthop_type          = string
  }))
  default = {}
}

# Route entries for region 2 VPC
variable "region_b_route_entries" {
  description = "Map of custom route entries for region 2 VPC route table"
  type = map(object({
    destination_cidrblock = string
    nexthop_type          = string
  }))
  default = {}
}

# Security group rules for region 1
variable "region_a_security_group_rules" {
  description = "Map of security group rules for region 1"
  type = map(object({
    type        = string
    ip_protocol = string
    nic_type    = string
    policy      = string
    port_range  = string
    priority    = number
    cidr_ip     = string
  }))
  default = {
    allow_ssh = {
      type        = "ingress"
      ip_protocol = "all"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "22/22"
      priority    = 1
      cidr_ip     = "0.0.0.0/0"
    }
  }
}

# Security group rules for region 2
variable "region_b_security_group_rules" {
  description = "Map of security group rules for region 2"
  type = map(object({
    type        = string
    ip_protocol = string
    nic_type    = string
    policy      = string
    port_range  = string
    priority    = number
    cidr_ip     = string
  }))
  default = {
    allow_ssh = {
      type        = "ingress"
      ip_protocol = "all"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "22/22"
      priority    = 1
      cidr_ip     = "0.0.0.0/0"
    }
  }
}

# ECS instances configuration for region 1
variable "region_a_ecs_instances" {
  description = "Map of ECS instances to create in region 1"
  type = map(object({
    instance_name        = string
    instance_type        = string
    vswitch_key          = string
    image_id             = string
    system_disk_category = string
    instance_charge_type = string
  }))
}

# ECS instances configuration for region 2
variable "region_b_ecs_instances" {
  description = "Map of ECS instances to create in region 2"
  type = map(object({
    instance_name        = string
    instance_type        = string
    vswitch_key          = string
    image_id             = string
    system_disk_category = string
    instance_charge_type = string
  }))
}

# ECS instance password
variable "ecs_instance_password" {
  description = "Password for ECS instances, must be 8-30 characters and include three of: uppercase, lowercase, numbers, special characters"
  type        = string
  sensitive   = true
}

# ECS command configuration
variable "ecs_command_name" {
  description = "Name of the ECS command for nginx installation"
  type        = string
  default     = "tf-test"
}

variable "ecs_command_type" {
  description = "Type of ECS command to execute"
  type        = string
  default     = "RunShellScript"
}

variable "ecs_command_working_dir" {
  description = "Working directory for ECS command execution"
  type        = string
  default     = "/root"
}

variable "ecs_command_enable_parameter" {
  description = "Whether to enable parameter substitution in ECS command"
  type        = bool
  default     = true
}

variable "custom_nginx_script" {
  description = "Custom nginx installation script to override the default one"
  type        = string
  default     = null
}

# PolarDB configuration
variable "polardb_config" {
  description = "PolarDB cluster configuration including database type, version, and node class"
  type = object({
    db_type                  = string
    db_version               = string
    db_node_class            = string
    pay_type                 = string
    description              = string
    loose_polar_log_bin      = string
    db_cluster_ip_array_name = string
  })
  default = {
    db_type                  = "MySQL"
    db_version               = "8.0"
    db_node_class            = "polar.mysql.x4.large"
    pay_type                 = "PostPaid"
    description              = "terraform-example"
    loose_polar_log_bin      = "ON"
    db_cluster_ip_array_name = "default"
  }
}

# PolarDB automatically uses the first vswitch (index 0) and whitelists all ECS instances

variable "polardb_account_name" {
  description = "Account name for PolarDB database"
  type        = string
  default     = "terraform"
}

variable "polardb_account_description" {
  description = "Description for PolarDB account"
  type        = string
  default     = "terraform-example"
}

variable "db_password" {
  description = "Password for PolarDB database, must be 8-32 characters and include uppercase, lowercase, numbers, and special characters"
  type        = string
  sensitive   = true
}

variable "polardb_database_name" {
  description = "Database name for PolarDB"
  type        = string
  default     = "tfexample"
}

variable "polardb_region_a_account_privilege" {
  description = "Account privilege for PolarDB in region 1"
  type        = string
  default     = "ReadOnly"
}

variable "polardb_region_b_account_privilege" {
  description = "Account privilege for PolarDB in region 2"
  type        = string
  default     = "ReadWrite"
}

# ALB configuration
variable "alb_config" {
  description = "Application Load Balancer configuration"
  type = object({
    address_type           = string
    address_allocated_mode = string
    load_balancer_name     = string
    load_balancer_edition  = string
    pay_type               = string
  })
  default = {
    address_type           = "Internet"
    address_allocated_mode = "Fixed"
    load_balancer_name     = "test_create_by_ros"
    load_balancer_edition  = "Basic"
    pay_type               = "PayAsYouGo"
  }
}

# ALB automatically uses all vswitches in each region

# ALB server group configuration
variable "alb_server_group_config" {
  description = "ALB server group configuration including health check and sticky session settings"
  type = object({
    protocol                  = string
    server_group_name         = string
    health_check_connect_port = string
    health_check_enabled      = bool
    health_check_host         = string
    health_check_codes        = list(string)
    health_check_http_version = string
    health_check_interval     = string
    health_check_method       = string
    health_check_path         = string
    health_check_protocol     = string
    health_check_timeout      = number
    healthy_threshold         = number
    unhealthy_threshold       = number
    sticky_session_enabled    = bool
    cookie                    = string
    sticky_session_type       = string
    server_port               = number
    server_type               = string
    server_weight             = number
  })
  default = {
    protocol                  = "HTTP"
    server_group_name         = "test_create_by_ros"
    health_check_connect_port = "46325"
    health_check_enabled      = true
    health_check_host         = "tf-example.com"
    health_check_codes        = ["http_2xx", "http_3xx"]
    health_check_http_version = "HTTP1.1"
    health_check_interval     = "2"
    health_check_method       = "HEAD"
    health_check_path         = "/tf-example"
    health_check_protocol     = "HTTP"
    health_check_timeout      = 5
    healthy_threshold         = 3
    unhealthy_threshold       = 3
    sticky_session_enabled    = true
    cookie                    = "tf-example"
    sticky_session_type       = "Server"
    server_port               = 80
    server_type               = "Ecs"
    server_weight             = 100
  }
}

# ALB server group automatically includes all ECS instances in each region

# ALB listener configuration
variable "alb_listener_config" {
  description = "ALB listener configuration"
  type = object({
    listener_protocol   = string
    listener_port       = number
    default_action_type = string
  })
  default = {
    listener_protocol   = "HTTP"
    listener_port       = 80
    default_action_type = "ForwardGroup"
  }
}

# CEN configuration
variable "cen_instance_name" {
  description = "Name of the CEN instance"
  type        = string
  default     = "two-location-three-center-BY-TERRAFORM"
}

variable "cen_region_a_vpc_attachment_name" {
  description = "Name of the VPC attachment for region 1"
  type        = string
  default     = "vpc_attachment_1"
}

variable "cen_region_b_vpc_attachment_name" {
  description = "Name of the VPC attachment for region 2"
  type        = string
  default     = "vpc_attachment_2"
}

# CEN transit router automatically uses all vswitches in each region

variable "region_a_cen_route_entries" {
  description = "Map of CEN transit router route entries for region 1"
  type = map(object({
    destination_cidr_block = string
    next_hop_type          = string
  }))
  default = {}
}

variable "region_b_cen_route_entries" {
  description = "Map of CEN transit router route entries for region 2"
  type = map(object({
    destination_cidr_block = string
    next_hop_type          = string
  }))
  default = {}
}

# CEN peer region is automatically retrieved from the transit router in region A

variable "cen_peer_bandwidth_type" {
  description = "Bandwidth type for CEN peer attachment"
  type        = string
  default     = "DataTransfer"
}

variable "cen_peer_bandwidth" {
  description = "Bandwidth in Gbps for CEN peer attachment"
  type        = number
  default     = 2
}

variable "cen_peer_auto_publish_route" {
  description = "Whether to enable auto publish route for CEN peer attachment"
  type        = bool
  default     = true
}

# DTS configuration
variable "dts_config" {
  description = "DTS instance configuration for database synchronization"
  type = object({
    type                             = string
    payment_type                     = string
    instance_class                   = string
    source_endpoint_engine_name      = string
    source_region                    = string
    destination_endpoint_engine_name = string
    destination_region               = string
  })
  default = {
    type                             = "sync"
    payment_type                     = "PayAsYouGo"
    instance_class                   = "small"
    source_endpoint_engine_name      = "PolarDB"
    source_region                    = "cn-hangzhou"
    destination_endpoint_engine_name = "PolarDB"
    destination_region               = "cn-shanghai"
  }
}
