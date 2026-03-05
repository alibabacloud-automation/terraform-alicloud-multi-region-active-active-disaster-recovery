Terraform module for Multi-Region Active-Active Disaster Recovery on Alibaba Cloud

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-multi-region-active-active-disaster-recovery/blob/main/README-CN.md)

# terraform-alicloud-multi-region-active-active-disaster-recovery

This Terraform module creates a comprehensive [multi-region active-active disaster recovery architecture on Alibaba Cloud](https://www.aliyun.com/solution/tech-solution/tltcamanidl), including VPCs, ECS instances, PolarDB clusters, ALB load balancers, and cross-region connectivity through CEN (Cloud Enterprise Network) for high availability and business continuity.

## Architecture

```
Region A                        Region B
┌─────────────────┐            ┌─────────────────┐
│      VPC A      │            │      VPC B      │
│  ┌───────────┐  │            │  ┌───────────┐  │
│  │ VSwitch   │  │            │  │ VSwitch   │  │
│  │ ┌───────┐ │  │            │  │ ┌───────┐ │  │
│  │ │  ECS  │ │  │            │  │ │  ECS  │ │  │
│  │ └───────┘ │  │            │  │ └───────┘ │  │
│  └───────────┘  │            │  └───────────┘  │
│  ┌───────────┐  │            │  ┌───────────┐  │
│  │ PolarDB   │  │            │  │ PolarDB   │  │
│  └───────────┘  │            │  └───────────┘  │
│  ┌───────────┐  │            │  ┌───────────┐  │
│  │    ALB    │  │            │  │    ALB    │  │
│  └───────────┘  │            │  └───────────┘  │
└─────────────────┘            └─────────────────┘
         │                              │
         └──────────┬───────────────────┘
                    │
              ┌─────────┐
              │   CEN   │
              └─────────┘
                    │
              ┌─────────┐
              │   DTS   │
              └─────────┘
```

## Usage

```hcl
provider "alicloud" {
  alias  = "region_A"
  region = "cn-shanghai"
}

provider "alicloud" {
  alias  = "region_B"
  region = "cn-beijing"
}

module "disaster_recovery" {
  source = "alibabacloud-automation/multi-region-active-active-disaster-recovery/alicloud"

  providers = {
    alicloud.region_A = alicloud.region_A
    alicloud.region_B = alicloud.region_B
  }

  # VPC configuration (optional - has defaults)
  region_a_vpc_config = {
    cidr_block = "10.0.0.0/16"
  }

  region_b_vpc_config = {
    cidr_block = "172.16.0.0/16"
  }

  # VSwitch configurations (required - must have exactly 2 per region)
  region_a_vswitch_configs = {
    vsw1 = {
      cidr_block = "10.0.1.0/24"
      zone_id    = "cn-shanghai-e"
    }
    vsw2 = {
      cidr_block = "10.0.2.0/24"
      zone_id    = "cn-shanghai-f"
    }
  }

  region_b_vswitch_configs = {
    vsw1 = {
      cidr_block = "172.16.1.0/24"
      zone_id    = "cn-beijing-k"
    }
    vsw2 = {
      cidr_block = "172.16.2.0/24"
      zone_id    = "cn-beijing-l"
    }
  }

  # ECS instances (required)
  region_a_ecs_instances = {
    app001 = {
      instance_name        = "APP001"
      instance_type        = "ecs.g8i.large"
      vswitch_key          = "vsw1"
      image_id             = "aliyun_3_x64_20G_alibase_20250629.vhd"
      system_disk_category = "cloud_essd"
      instance_charge_type = "PostPaid"
    }
  }

  region_b_ecs_instances = {
    app002 = {
      instance_name        = "APP002"
      instance_type        = "ecs.g7.large"
      vswitch_key          = "vsw1"
      image_id             = "aliyun_3_x64_20G_alibase_20250629.vhd"
      system_disk_category = "cloud_essd"
      instance_charge_type = "PostPaid"
    }
  }

  # Passwords (required)
  ecs_instance_password = "YourPassword123!"
  db_password           = "YourDBPassword123!"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.210.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | >= 1.210.0 |
| <a name="provider_alicloud.region_A"></a> [alicloud.region\_A](#provider\_alicloud.region\_A) | >= 1.210.0 |
| <a name="provider_alicloud.region_B"></a> [alicloud.region\_B](#provider\_alicloud.region\_B) | >= 1.210.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_alb_listener.listener_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_listener) | resource |
| [alicloud_alb_listener.listener_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_listener) | resource |
| [alicloud_alb_load_balancer.alb_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_load_balancer) | resource |
| [alicloud_alb_load_balancer.alb_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_load_balancer) | resource |
| [alicloud_alb_server_group.server_group_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_server_group) | resource |
| [alicloud_alb_server_group.server_group_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_server_group) | resource |
| [alicloud_cen_instance.cen](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_instance) | resource |
| [alicloud_cen_transit_router.tr_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router) | resource |
| [alicloud_cen_transit_router.tr_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router) | resource |
| [alicloud_cen_transit_router_peer_attachment.peer_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_peer_attachment) | resource |
| [alicloud_cen_transit_router_route_entry.route_entry_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_entry) | resource |
| [alicloud_cen_transit_router_route_entry.route_entry_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_entry) | resource |
| [alicloud_cen_transit_router_route_table.route_table_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table) | resource |
| [alicloud_cen_transit_router_route_table.route_table_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table) | resource |
| [alicloud_cen_transit_router_route_table_association.association_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource |
| [alicloud_cen_transit_router_route_table_association.association_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource |
| [alicloud_cen_transit_router_route_table_association.association_c](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource |
| [alicloud_cen_transit_router_route_table_association.association_d](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource |
| [alicloud_cen_transit_router_route_table_propagation.propagation_c](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_propagation) | resource |
| [alicloud_cen_transit_router_route_table_propagation.propagation_d](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_propagation) | resource |
| [alicloud_cen_transit_router_vpc_attachment.vpc_att_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_vpc_attachment) | resource |
| [alicloud_cen_transit_router_vpc_attachment.vpc_att_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_vpc_attachment) | resource |
| [alicloud_dts_instance.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/dts_instance) | resource |
| [alicloud_ecs_command.cmd_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_command.cmd_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_invocation.region_a_invocations](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_ecs_invocation.region_b_invocations](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_instance.region_a_instances](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_instance.region_b_instances](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_polardb_account.polardb_account_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_account) | resource |
| [alicloud_polardb_account.polardb_account_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_account) | resource |
| [alicloud_polardb_account_privilege.privilege_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_account_privilege) | resource |
| [alicloud_polardb_account_privilege.privilege_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_account_privilege) | resource |
| [alicloud_polardb_cluster.polardb_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_cluster) | resource |
| [alicloud_polardb_cluster.polardb_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_cluster) | resource |
| [alicloud_polardb_database.polardb_database_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_database) | resource |
| [alicloud_polardb_database.polardb_database_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_database) | resource |
| [alicloud_route_entry.region_a_routes](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/route_entry) | resource |
| [alicloud_route_entry.region_b_routes](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/route_entry) | resource |
| [alicloud_security_group.group_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group.group_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.region_a_rules](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_security_group_rule.region_b_rules](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_vpc.vpc_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vpc.vpc_b](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.region_a_vswitches](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_vswitch.region_b_vswitches](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_regions.region_a](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/regions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_config"></a> [alb\_config](#input\_alb\_config) | Application Load Balancer configuration | <pre>object({<br/>    address_type           = string<br/>    address_allocated_mode = string<br/>    load_balancer_name     = string<br/>    load_balancer_edition  = string<br/>    pay_type               = string<br/>  })</pre> | <pre>{<br/>  "address_allocated_mode": "Fixed",<br/>  "address_type": "Internet",<br/>  "load_balancer_edition": "Basic",<br/>  "load_balancer_name": "test_create_by_ros",<br/>  "pay_type": "PayAsYouGo"<br/>}</pre> | no |
| <a name="input_alb_listener_config"></a> [alb\_listener\_config](#input\_alb\_listener\_config) | ALB listener configuration | <pre>object({<br/>    listener_protocol   = string<br/>    listener_port       = number<br/>    default_action_type = string<br/>  })</pre> | <pre>{<br/>  "default_action_type": "ForwardGroup",<br/>  "listener_port": 80,<br/>  "listener_protocol": "HTTP"<br/>}</pre> | no |
| <a name="input_alb_server_group_config"></a> [alb\_server\_group\_config](#input\_alb\_server\_group\_config) | ALB server group configuration including health check and sticky session settings | <pre>object({<br/>    protocol                  = string<br/>    server_group_name         = string<br/>    health_check_connect_port = string<br/>    health_check_enabled      = bool<br/>    health_check_host         = string<br/>    health_check_codes        = list(string)<br/>    health_check_http_version = string<br/>    health_check_interval     = string<br/>    health_check_method       = string<br/>    health_check_path         = string<br/>    health_check_protocol     = string<br/>    health_check_timeout      = number<br/>    healthy_threshold         = number<br/>    unhealthy_threshold       = number<br/>    sticky_session_enabled    = bool<br/>    cookie                    = string<br/>    sticky_session_type       = string<br/>    server_port               = number<br/>    server_type               = string<br/>    server_weight             = number<br/>  })</pre> | <pre>{<br/>  "cookie": "tf-example",<br/>  "health_check_codes": [<br/>    "http_2xx",<br/>    "http_3xx"<br/>  ],<br/>  "health_check_connect_port": "46325",<br/>  "health_check_enabled": true,<br/>  "health_check_host": "tf-example.com",<br/>  "health_check_http_version": "HTTP1.1",<br/>  "health_check_interval": "2",<br/>  "health_check_method": "HEAD",<br/>  "health_check_path": "/tf-example",<br/>  "health_check_protocol": "HTTP",<br/>  "health_check_timeout": 5,<br/>  "healthy_threshold": 3,<br/>  "protocol": "HTTP",<br/>  "server_group_name": "test_create_by_ros",<br/>  "server_port": 80,<br/>  "server_type": "Ecs",<br/>  "server_weight": 100,<br/>  "sticky_session_enabled": true,<br/>  "sticky_session_type": "Server",<br/>  "unhealthy_threshold": 3<br/>}</pre> | no |
| <a name="input_cen_instance_name"></a> [cen\_instance\_name](#input\_cen\_instance\_name) | Name of the CEN instance | `string` | `"two-location-three-center-BY-TERRAFORM"` | no |
| <a name="input_cen_peer_auto_publish_route"></a> [cen\_peer\_auto\_publish\_route](#input\_cen\_peer\_auto\_publish\_route) | Whether to enable auto publish route for CEN peer attachment | `bool` | `true` | no |
| <a name="input_cen_peer_bandwidth"></a> [cen\_peer\_bandwidth](#input\_cen\_peer\_bandwidth) | Bandwidth in Gbps for CEN peer attachment | `number` | `2` | no |
| <a name="input_cen_peer_bandwidth_type"></a> [cen\_peer\_bandwidth\_type](#input\_cen\_peer\_bandwidth\_type) | Bandwidth type for CEN peer attachment | `string` | `"DataTransfer"` | no |
| <a name="input_cen_region_a_vpc_attachment_name"></a> [cen\_region\_a\_vpc\_attachment\_name](#input\_cen\_region\_a\_vpc\_attachment\_name) | Name of the VPC attachment for region 1 | `string` | `"vpc_attachment_1"` | no |
| <a name="input_cen_region_b_vpc_attachment_name"></a> [cen\_region\_b\_vpc\_attachment\_name](#input\_cen\_region\_b\_vpc\_attachment\_name) | Name of the VPC attachment for region 2 | `string` | `"vpc_attachment_2"` | no |
| <a name="input_custom_nginx_script"></a> [custom\_nginx\_script](#input\_custom\_nginx\_script) | Custom nginx installation script to override the default one | `string` | `null` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Password for PolarDB database, must be 8-32 characters and include uppercase, lowercase, numbers, and special characters | `string` | n/a | yes |
| <a name="input_dts_config"></a> [dts\_config](#input\_dts\_config) | DTS instance configuration for database synchronization | <pre>object({<br/>    type                             = string<br/>    payment_type                     = string<br/>    instance_class                   = string<br/>    source_endpoint_engine_name      = string<br/>    source_region                    = string<br/>    destination_endpoint_engine_name = string<br/>    destination_region               = string<br/>  })</pre> | <pre>{<br/>  "destination_endpoint_engine_name": "PolarDB",<br/>  "destination_region": "cn-shanghai",<br/>  "instance_class": "small",<br/>  "payment_type": "PayAsYouGo",<br/>  "source_endpoint_engine_name": "PolarDB",<br/>  "source_region": "cn-hangzhou",<br/>  "type": "sync"<br/>}</pre> | no |
| <a name="input_ecs_command_enable_parameter"></a> [ecs\_command\_enable\_parameter](#input\_ecs\_command\_enable\_parameter) | Whether to enable parameter substitution in ECS command | `bool` | `true` | no |
| <a name="input_ecs_command_name"></a> [ecs\_command\_name](#input\_ecs\_command\_name) | Name of the ECS command for nginx installation | `string` | `"tf-test"` | no |
| <a name="input_ecs_command_type"></a> [ecs\_command\_type](#input\_ecs\_command\_type) | Type of ECS command to execute | `string` | `"RunShellScript"` | no |
| <a name="input_ecs_command_working_dir"></a> [ecs\_command\_working\_dir](#input\_ecs\_command\_working\_dir) | Working directory for ECS command execution | `string` | `"/root"` | no |
| <a name="input_ecs_instance_password"></a> [ecs\_instance\_password](#input\_ecs\_instance\_password) | Password for ECS instances, must be 8-30 characters and include three of: uppercase, lowercase, numbers, special characters | `string` | n/a | yes |
| <a name="input_polardb_account_description"></a> [polardb\_account\_description](#input\_polardb\_account\_description) | Description for PolarDB account | `string` | `"terraform-example"` | no |
| <a name="input_polardb_account_name"></a> [polardb\_account\_name](#input\_polardb\_account\_name) | Account name for PolarDB database | `string` | `"terraform"` | no |
| <a name="input_polardb_config"></a> [polardb\_config](#input\_polardb\_config) | PolarDB cluster configuration including database type, version, and node class | <pre>object({<br/>    db_type                  = string<br/>    db_version               = string<br/>    db_node_class            = string<br/>    pay_type                 = string<br/>    description              = string<br/>    loose_polar_log_bin      = string<br/>    db_cluster_ip_array_name = string<br/>  })</pre> | <pre>{<br/>  "db_cluster_ip_array_name": "default",<br/>  "db_node_class": "polar.mysql.x4.large",<br/>  "db_type": "MySQL",<br/>  "db_version": "8.0",<br/>  "description": "terraform-example",<br/>  "loose_polar_log_bin": "ON",<br/>  "pay_type": "PostPaid"<br/>}</pre> | no |
| <a name="input_polardb_database_name"></a> [polardb\_database\_name](#input\_polardb\_database\_name) | Database name for PolarDB | `string` | `"tfexample"` | no |
| <a name="input_polardb_region_a_account_privilege"></a> [polardb\_region\_a\_account\_privilege](#input\_polardb\_region\_a\_account\_privilege) | Account privilege for PolarDB in region 1 | `string` | `"ReadOnly"` | no |
| <a name="input_polardb_region_b_account_privilege"></a> [polardb\_region\_b\_account\_privilege](#input\_polardb\_region\_b\_account\_privilege) | Account privilege for PolarDB in region 2 | `string` | `"ReadWrite"` | no |
| <a name="input_region_a_cen_route_entries"></a> [region\_a\_cen\_route\_entries](#input\_region\_a\_cen\_route\_entries) | Map of CEN transit router route entries for region 1 | <pre>map(object({<br/>    destination_cidr_block = string<br/>    next_hop_type          = string<br/>  }))</pre> | `{}` | no |
| <a name="input_region_a_ecs_instances"></a> [region\_a\_ecs\_instances](#input\_region\_a\_ecs\_instances) | Map of ECS instances to create in region 1 | <pre>map(object({<br/>    instance_name        = string<br/>    instance_type        = string<br/>    vswitch_key          = string<br/>    image_id             = string<br/>    system_disk_category = string<br/>    instance_charge_type = string<br/>  }))</pre> | n/a | yes |
| <a name="input_region_a_route_entries"></a> [region\_a\_route\_entries](#input\_region\_a\_route\_entries) | Map of custom route entries for region 1 VPC route table | <pre>map(object({<br/>    destination_cidrblock = string<br/>    nexthop_type          = string<br/>  }))</pre> | `{}` | no |
| <a name="input_region_a_security_group_rules"></a> [region\_a\_security\_group\_rules](#input\_region\_a\_security\_group\_rules) | Map of security group rules for region 1 | <pre>map(object({<br/>    type        = string<br/>    ip_protocol = string<br/>    nic_type    = string<br/>    policy      = string<br/>    port_range  = string<br/>    priority    = number<br/>    cidr_ip     = string<br/>  }))</pre> | <pre>{<br/>  "allow_ssh": {<br/>    "cidr_ip": "0.0.0.0/0",<br/>    "ip_protocol": "all",<br/>    "nic_type": "intranet",<br/>    "policy": "accept",<br/>    "port_range": "22/22",<br/>    "priority": 1,<br/>    "type": "ingress"<br/>  }<br/>}</pre> | no |
| <a name="input_region_a_vpc_config"></a> [region\_a\_vpc\_config](#input\_region\_a\_vpc\_config) | VPC configuration for primary region including VPC name and CIDR block | <pre>object({<br/>    vpc_name   = optional(string, "vpc1")<br/>    cidr_block = string<br/>  })</pre> | n/a | yes |
| <a name="input_region_a_vswitch_configs"></a> [region\_a\_vswitch\_configs](#input\_region\_a\_vswitch\_configs) | Map of vswitch configurations for region 1, each with CIDR block and zone ID. Must contain exactly 2 vswitches. | <pre>map(object({<br/>    cidr_block = string<br/>    zone_id    = string<br/>  }))</pre> | n/a | yes |
| <a name="input_region_b_cen_route_entries"></a> [region\_b\_cen\_route\_entries](#input\_region\_b\_cen\_route\_entries) | Map of CEN transit router route entries for region 2 | <pre>map(object({<br/>    destination_cidr_block = string<br/>    next_hop_type          = string<br/>  }))</pre> | `{}` | no |
| <a name="input_region_b_ecs_instances"></a> [region\_b\_ecs\_instances](#input\_region\_b\_ecs\_instances) | Map of ECS instances to create in region 2 | <pre>map(object({<br/>    instance_name        = string<br/>    instance_type        = string<br/>    vswitch_key          = string<br/>    image_id             = string<br/>    system_disk_category = string<br/>    instance_charge_type = string<br/>  }))</pre> | n/a | yes |
| <a name="input_region_b_route_entries"></a> [region\_b\_route\_entries](#input\_region\_b\_route\_entries) | Map of custom route entries for region 2 VPC route table | <pre>map(object({<br/>    destination_cidrblock = string<br/>    nexthop_type          = string<br/>  }))</pre> | `{}` | no |
| <a name="input_region_b_security_group_rules"></a> [region\_b\_security\_group\_rules](#input\_region\_b\_security\_group\_rules) | Map of security group rules for region 2 | <pre>map(object({<br/>    type        = string<br/>    ip_protocol = string<br/>    nic_type    = string<br/>    policy      = string<br/>    port_range  = string<br/>    priority    = number<br/>    cidr_ip     = string<br/>  }))</pre> | <pre>{<br/>  "allow_ssh": {<br/>    "cidr_ip": "0.0.0.0/0",<br/>    "ip_protocol": "all",<br/>    "nic_type": "intranet",<br/>    "policy": "accept",<br/>    "port_range": "22/22",<br/>    "priority": 1,<br/>    "type": "ingress"<br/>  }<br/>}</pre> | no |
| <a name="input_region_b_vpc_config"></a> [region\_b\_vpc\_config](#input\_region\_b\_vpc\_config) | VPC configuration for secondary region including VPC name and CIDR block | <pre>object({<br/>    vpc_name   = optional(string, "vpc2")<br/>    cidr_block = string<br/>  })</pre> | n/a | yes |
| <a name="input_region_b_vswitch_configs"></a> [region\_b\_vswitch\_configs](#input\_region\_b\_vswitch\_configs) | Map of vswitch configurations for region 2, each with CIDR block and zone ID. Must contain exactly 2 vswitches. | <pre>map(object({<br/>    cidr_block = string<br/>    zone_id    = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cen_instance_id"></a> [cen\_instance\_id](#output\_cen\_instance\_id) | ID of the CEN instance |
| <a name="output_dts_instance_id"></a> [dts\_instance\_id](#output\_dts\_instance\_id) | ID of the DTS instance for database synchronization |
| <a name="output_region_a_alb_dns_name"></a> [region\_a\_alb\_dns\_name](#output\_region\_a\_alb\_dns\_name) | DNS name of the Application Load Balancer in region 1 |
| <a name="output_region_a_alb_id"></a> [region\_a\_alb\_id](#output\_region\_a\_alb\_id) | ID of the Application Load Balancer in region 1 |
| <a name="output_region_a_alb_status"></a> [region\_a\_alb\_status](#output\_region\_a\_alb\_status) | Status of the Application Load Balancer in region 1 |
| <a name="output_region_a_instance_ids"></a> [region\_a\_instance\_ids](#output\_region\_a\_instance\_ids) | Map of ECS instance IDs in region 1 |
| <a name="output_region_a_instance_private_ips"></a> [region\_a\_instance\_private\_ips](#output\_region\_a\_instance\_private\_ips) | Map of ECS instance private IPs in region 1 |
| <a name="output_region_a_polardb_cluster_id"></a> [region\_a\_polardb\_cluster\_id](#output\_region\_a\_polardb\_cluster\_id) | ID of the PolarDB cluster in region 1 |
| <a name="output_region_a_polardb_connection_string"></a> [region\_a\_polardb\_connection\_string](#output\_region\_a\_polardb\_connection\_string) | Connection string of the PolarDB cluster in region 1 |
| <a name="output_region_a_security_group_id"></a> [region\_a\_security\_group\_id](#output\_region\_a\_security\_group\_id) | ID of the security group in region 1 |
| <a name="output_region_a_transit_router_id"></a> [region\_a\_transit\_router\_id](#output\_region\_a\_transit\_router\_id) | ID of the CEN transit router in region 1 |
| <a name="output_region_a_vpc_attachment_id"></a> [region\_a\_vpc\_attachment\_id](#output\_region\_a\_vpc\_attachment\_id) | ID of the CEN VPC attachment in region 1 |
| <a name="output_region_a_vpc_id"></a> [region\_a\_vpc\_id](#output\_region\_a\_vpc\_id) | ID of the VPC in region 1 |
| <a name="output_region_a_vswitch_ids"></a> [region\_a\_vswitch\_ids](#output\_region\_a\_vswitch\_ids) | Map of vswitch IDs in region 1 |
| <a name="output_region_b_alb_dns_name"></a> [region\_b\_alb\_dns\_name](#output\_region\_b\_alb\_dns\_name) | DNS name of the Application Load Balancer in region 2 |
| <a name="output_region_b_alb_id"></a> [region\_b\_alb\_id](#output\_region\_b\_alb\_id) | ID of the Application Load Balancer in region 2 |
| <a name="output_region_b_alb_status"></a> [region\_b\_alb\_status](#output\_region\_b\_alb\_status) | Status of the Application Load Balancer in region 2 |
| <a name="output_region_b_instance_ids"></a> [region\_b\_instance\_ids](#output\_region\_b\_instance\_ids) | Map of ECS instance IDs in region 2 |
| <a name="output_region_b_instance_private_ips"></a> [region\_b\_instance\_private\_ips](#output\_region\_b\_instance\_private\_ips) | Map of ECS instance private IPs in region 2 |
| <a name="output_region_b_polardb_cluster_id"></a> [region\_b\_polardb\_cluster\_id](#output\_region\_b\_polardb\_cluster\_id) | ID of the PolarDB cluster in region 2 |
| <a name="output_region_b_polardb_connection_string"></a> [region\_b\_polardb\_connection\_string](#output\_region\_b\_polardb\_connection\_string) | Connection string of the PolarDB cluster in region 2 |
| <a name="output_region_b_security_group_id"></a> [region\_b\_security\_group\_id](#output\_region\_b\_security\_group\_id) | ID of the security group in region 2 |
| <a name="output_region_b_transit_router_id"></a> [region\_b\_transit\_router\_id](#output\_region\_b\_transit\_router\_id) | ID of the CEN transit router in region 2 |
| <a name="output_region_b_vpc_attachment_id"></a> [region\_b\_vpc\_attachment\_id](#output\_region\_b\_vpc\_attachment\_id) | ID of the CEN VPC attachment in region 2 |
| <a name="output_region_b_vpc_id"></a> [region\_b\_vpc\_id](#output\_region\_b\_vpc\_id) | ID of the VPC in region 2 |
| <a name="output_region_b_vswitch_ids"></a> [region\_b\_vswitch\_ids](#output\_region\_b\_vswitch\_ids) | Map of vswitch IDs in region 2 |
<!-- END_TF_DOCS -->

## Examples

* [complete](https://github.com/alibabacloud-automation/terraform-alicloud-multi-region-active-active-disaster-recovery/tree/main/examples/complete)

## Submit Issues

If you have any problems when using this module, please opening a [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There should not be any homemade issue labels (e.g. bug, new) in the issue. The Terraform provider official will add them.

## Authors

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## License

MIT Licensed. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)
