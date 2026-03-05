# Multi-region active-active disaster recovery architecture
# This module deploys resources across two regions for high availability

# Get current region information for both providers
data "alicloud_regions" "region_a" {
  provider = alicloud.region_A
  current  = true
}

# Extract initialization script for ECS instances
locals {
  default_nginx_script = <<-EOF
echo "this is {{instance_name}}"
yum install -y nginx
systemctl start nginx.service
cd /usr/share/nginx/html/
echo "Hello World ! This is {{instance_name}}." > index.html
cat index.html
service nginx status
curl localhost
EOF
}

# Region 1 VPC and vswitches
resource "alicloud_vpc" "vpc_a" {
  provider   = alicloud.region_A
  vpc_name   = var.region_a_vpc_config.vpc_name
  cidr_block = var.region_a_vpc_config.cidr_block
}

resource "alicloud_vswitch" "region_a_vswitches" {
  for_each = var.region_a_vswitch_configs

  provider   = alicloud.region_A
  vpc_id     = alicloud_vpc.vpc_a.id
  cidr_block = each.value.cidr_block
  zone_id    = each.value.zone_id
}

# Region 2 VPC and vswitches
resource "alicloud_vpc" "vpc_b" {
  provider   = alicloud.region_B
  vpc_name   = var.region_b_vpc_config.vpc_name
  cidr_block = var.region_b_vpc_config.cidr_block
}

resource "alicloud_vswitch" "region_b_vswitches" {
  for_each = var.region_b_vswitch_configs

  provider   = alicloud.region_B
  vpc_id     = alicloud_vpc.vpc_b.id
  cidr_block = each.value.cidr_block
  zone_id    = each.value.zone_id
}

# Route entries for region 1
resource "alicloud_route_entry" "region_a_routes" {
  for_each = var.region_a_route_entries

  provider              = alicloud.region_A
  route_table_id        = alicloud_vpc.vpc_a.route_table_id
  destination_cidrblock = each.value.destination_cidrblock
  nexthop_type          = each.value.nexthop_type
  nexthop_id            = alicloud_cen_transit_router_vpc_attachment.vpc_att_a.transit_router_attachment_id
}

# Route entries for region 2
resource "alicloud_route_entry" "region_b_routes" {
  for_each = var.region_b_route_entries

  provider              = alicloud.region_B
  route_table_id        = alicloud_vpc.vpc_b.route_table_id
  destination_cidrblock = each.value.destination_cidrblock
  nexthop_type          = each.value.nexthop_type
  nexthop_id            = alicloud_cen_transit_router_vpc_attachment.vpc_att_b.transit_router_attachment_id
}

# Security groups
resource "alicloud_security_group" "group_a" {
  provider = alicloud.region_A
  vpc_id   = alicloud_vpc.vpc_a.id
}

resource "alicloud_security_group" "group_b" {
  provider = alicloud.region_B
  vpc_id   = alicloud_vpc.vpc_b.id
}

# Security group rules for region 1
resource "alicloud_security_group_rule" "region_a_rules" {
  for_each = var.region_a_security_group_rules

  provider          = alicloud.region_A
  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  nic_type          = each.value.nic_type
  policy            = each.value.policy
  port_range        = each.value.port_range
  priority          = each.value.priority
  security_group_id = alicloud_security_group.group_a.id
  cidr_ip           = each.value.cidr_ip
}

# Security group rules for region 2
resource "alicloud_security_group_rule" "region_b_rules" {
  for_each = var.region_b_security_group_rules

  provider          = alicloud.region_B
  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  nic_type          = each.value.nic_type
  policy            = each.value.policy
  port_range        = each.value.port_range
  priority          = each.value.priority
  security_group_id = alicloud_security_group.group_b.id
  cidr_ip           = each.value.cidr_ip
}

# ECS instances in region 1
resource "alicloud_instance" "region_a_instances" {
  for_each = var.region_a_ecs_instances

  provider             = alicloud.region_A
  instance_name        = each.value.instance_name
  instance_type        = each.value.instance_type
  security_groups      = [alicloud_security_group.group_a.id]
  vswitch_id           = alicloud_vswitch.region_a_vswitches[each.value.vswitch_key].id
  image_id             = each.value.image_id
  system_disk_category = each.value.system_disk_category
  instance_charge_type = each.value.instance_charge_type
  password             = var.ecs_instance_password
}

# ECS instances in region 2
resource "alicloud_instance" "region_b_instances" {
  for_each = var.region_b_ecs_instances

  provider             = alicloud.region_B
  instance_name        = each.value.instance_name
  instance_type        = each.value.instance_type
  security_groups      = [alicloud_security_group.group_b.id]
  vswitch_id           = alicloud_vswitch.region_b_vswitches[each.value.vswitch_key].id
  image_id             = each.value.image_id
  system_disk_category = each.value.system_disk_category
  instance_charge_type = each.value.instance_charge_type
  password             = var.ecs_instance_password
}

# ECS commands for nginx installation
resource "alicloud_ecs_command" "cmd_a" {
  provider         = alicloud.region_A
  name             = var.ecs_command_name
  command_content  = base64encode(var.custom_nginx_script != null ? var.custom_nginx_script : local.default_nginx_script)
  type             = var.ecs_command_type
  working_dir      = var.ecs_command_working_dir
  enable_parameter = var.ecs_command_enable_parameter
}

resource "alicloud_ecs_command" "cmd_b" {
  provider         = alicloud.region_B
  name             = var.ecs_command_name
  command_content  = base64encode(var.custom_nginx_script != null ? var.custom_nginx_script : local.default_nginx_script)
  type             = var.ecs_command_type
  working_dir      = var.ecs_command_working_dir
  enable_parameter = var.ecs_command_enable_parameter
}

# ECS invocations for region 1
resource "alicloud_ecs_invocation" "region_a_invocations" {
  for_each = var.region_a_ecs_instances

  provider    = alicloud.region_A
  command_id  = alicloud_ecs_command.cmd_a.id
  instance_id = [alicloud_instance.region_a_instances[each.key].id]
  parameters = {
    instance_name = alicloud_instance.region_a_instances[each.key].instance_name
  }
}

# ECS invocations for region 2
resource "alicloud_ecs_invocation" "region_b_invocations" {
  for_each = var.region_b_ecs_instances

  provider    = alicloud.region_B
  command_id  = alicloud_ecs_command.cmd_b.id
  instance_id = [alicloud_instance.region_b_instances[each.key].id]
  parameters = {
    instance_name = alicloud_instance.region_b_instances[each.key].instance_name
  }
}

# PolarDB clusters
resource "alicloud_polardb_cluster" "polardb_a" {
  provider            = alicloud.region_A
  db_type             = var.polardb_config.db_type
  db_version          = var.polardb_config.db_version
  db_node_class       = var.polardb_config.db_node_class
  pay_type            = var.polardb_config.pay_type
  vswitch_id          = values(alicloud_vswitch.region_a_vswitches)[0].id
  description         = var.polardb_config.description
  loose_polar_log_bin = var.polardb_config.loose_polar_log_bin

  db_cluster_ip_array {
    db_cluster_ip_array_name = var.polardb_config.db_cluster_ip_array_name
    security_ips = [
      for instance in alicloud_instance.region_a_instances :
      instance.private_ip
    ]
  }
}

resource "alicloud_polardb_cluster" "polardb_b" {
  provider            = alicloud.region_B
  db_type             = var.polardb_config.db_type
  db_version          = var.polardb_config.db_version
  db_node_class       = var.polardb_config.db_node_class
  pay_type            = var.polardb_config.pay_type
  vswitch_id          = values(alicloud_vswitch.region_b_vswitches)[0].id
  description         = var.polardb_config.description
  loose_polar_log_bin = var.polardb_config.loose_polar_log_bin

  db_cluster_ip_array {
    db_cluster_ip_array_name = var.polardb_config.db_cluster_ip_array_name
    security_ips = [
      for instance in alicloud_instance.region_b_instances :
      instance.private_ip
    ]
  }
}

# PolarDB accounts
resource "alicloud_polardb_account" "polardb_account_a" {
  provider            = alicloud.region_A
  db_cluster_id       = alicloud_polardb_cluster.polardb_a.id
  account_name        = var.polardb_account_name
  account_password    = var.db_password
  account_description = var.polardb_account_description
}

resource "alicloud_polardb_account" "polardb_account_b" {
  provider            = alicloud.region_B
  db_cluster_id       = alicloud_polardb_cluster.polardb_b.id
  account_name        = var.polardb_account_name
  account_password    = var.db_password
  account_description = var.polardb_account_description
}

# PolarDB databases
resource "alicloud_polardb_database" "polardb_database_a" {
  provider      = alicloud.region_A
  db_cluster_id = alicloud_polardb_cluster.polardb_a.id
  db_name       = var.polardb_database_name
  lifecycle {
    ignore_changes = [account_name]
  }
}

resource "alicloud_polardb_database" "polardb_database_b" {
  provider      = alicloud.region_B
  db_cluster_id = alicloud_polardb_cluster.polardb_b.id
  db_name       = var.polardb_database_name
  lifecycle {
    ignore_changes = [account_name]
  }
}

# PolarDB account privileges
resource "alicloud_polardb_account_privilege" "privilege_a" {
  provider          = alicloud.region_A
  db_cluster_id     = alicloud_polardb_cluster.polardb_a.id
  account_name      = alicloud_polardb_account.polardb_account_a.account_name
  account_privilege = var.polardb_region_a_account_privilege
  db_names          = [alicloud_polardb_database.polardb_database_a.db_name]
}

resource "alicloud_polardb_account_privilege" "privilege_b" {
  provider          = alicloud.region_B
  db_cluster_id     = alicloud_polardb_cluster.polardb_b.id
  account_name      = alicloud_polardb_account.polardb_account_b.account_name
  account_privilege = var.polardb_region_b_account_privilege
  db_names          = [alicloud_polardb_database.polardb_database_b.db_name]
}

# Application Load Balancers
resource "alicloud_alb_load_balancer" "alb_a" {
  provider               = alicloud.region_A
  vpc_id                 = alicloud_vpc.vpc_a.id
  address_type           = var.alb_config.address_type
  address_allocated_mode = var.alb_config.address_allocated_mode
  load_balancer_name     = var.alb_config.load_balancer_name
  load_balancer_edition  = var.alb_config.load_balancer_edition

  load_balancer_billing_config {
    pay_type = var.alb_config.pay_type
  }

  dynamic "zone_mappings" {
    for_each = alicloud_vswitch.region_a_vswitches
    content {
      vswitch_id = zone_mappings.value.id
      zone_id    = zone_mappings.value.zone_id
    }
  }
}

resource "alicloud_alb_load_balancer" "alb_b" {
  provider               = alicloud.region_B
  vpc_id                 = alicloud_vpc.vpc_b.id
  address_type           = var.alb_config.address_type
  address_allocated_mode = var.alb_config.address_allocated_mode
  load_balancer_name     = var.alb_config.load_balancer_name
  load_balancer_edition  = var.alb_config.load_balancer_edition

  load_balancer_billing_config {
    pay_type = var.alb_config.pay_type
  }

  dynamic "zone_mappings" {
    for_each = alicloud_vswitch.region_b_vswitches
    content {
      vswitch_id = zone_mappings.value.id
      zone_id    = zone_mappings.value.zone_id
    }
  }
}

# ALB server groups
resource "alicloud_alb_server_group" "server_group_a" {
  provider          = alicloud.region_A
  protocol          = var.alb_server_group_config.protocol
  vpc_id            = alicloud_vpc.vpc_a.id
  server_group_name = var.alb_server_group_config.server_group_name

  health_check_config {
    health_check_connect_port = var.alb_server_group_config.health_check_connect_port
    health_check_enabled      = var.alb_server_group_config.health_check_enabled
    health_check_host         = var.alb_server_group_config.health_check_host
    health_check_codes        = var.alb_server_group_config.health_check_codes
    health_check_http_version = var.alb_server_group_config.health_check_http_version
    health_check_interval     = var.alb_server_group_config.health_check_interval
    health_check_method       = var.alb_server_group_config.health_check_method
    health_check_path         = var.alb_server_group_config.health_check_path
    health_check_protocol     = var.alb_server_group_config.health_check_protocol
    health_check_timeout      = var.alb_server_group_config.health_check_timeout
    healthy_threshold         = var.alb_server_group_config.healthy_threshold
    unhealthy_threshold       = var.alb_server_group_config.unhealthy_threshold
  }

  sticky_session_config {
    sticky_session_enabled = var.alb_server_group_config.sticky_session_enabled
    cookie                 = var.alb_server_group_config.cookie
    sticky_session_type    = var.alb_server_group_config.sticky_session_type
  }

  dynamic "servers" {
    for_each = alicloud_instance.region_a_instances
    content {
      port        = var.alb_server_group_config.server_port
      server_id   = servers.value.id
      server_ip   = servers.value.private_ip
      server_type = var.alb_server_group_config.server_type
      weight      = var.alb_server_group_config.server_weight
    }
  }
}

resource "alicloud_alb_server_group" "server_group_b" {
  provider          = alicloud.region_B
  protocol          = var.alb_server_group_config.protocol
  vpc_id            = alicloud_vpc.vpc_b.id
  server_group_name = var.alb_server_group_config.server_group_name

  health_check_config {
    health_check_connect_port = var.alb_server_group_config.health_check_connect_port
    health_check_enabled      = var.alb_server_group_config.health_check_enabled
    health_check_host         = var.alb_server_group_config.health_check_host
    health_check_codes        = var.alb_server_group_config.health_check_codes
    health_check_http_version = var.alb_server_group_config.health_check_http_version
    health_check_interval     = var.alb_server_group_config.health_check_interval
    health_check_method       = var.alb_server_group_config.health_check_method
    health_check_path         = var.alb_server_group_config.health_check_path
    health_check_protocol     = var.alb_server_group_config.health_check_protocol
    health_check_timeout      = var.alb_server_group_config.health_check_timeout
    healthy_threshold         = var.alb_server_group_config.healthy_threshold
    unhealthy_threshold       = var.alb_server_group_config.unhealthy_threshold
  }

  sticky_session_config {
    sticky_session_enabled = var.alb_server_group_config.sticky_session_enabled
    cookie                 = var.alb_server_group_config.cookie
    sticky_session_type    = var.alb_server_group_config.sticky_session_type
  }

  dynamic "servers" {
    for_each = alicloud_instance.region_b_instances
    content {
      port        = var.alb_server_group_config.server_port
      server_id   = servers.value.id
      server_ip   = servers.value.private_ip
      server_type = var.alb_server_group_config.server_type
      weight      = var.alb_server_group_config.server_weight
    }
  }
}

# ALB listeners
resource "alicloud_alb_listener" "listener_a" {
  provider          = alicloud.region_A
  load_balancer_id  = alicloud_alb_load_balancer.alb_a.id
  listener_protocol = var.alb_listener_config.listener_protocol
  listener_port     = var.alb_listener_config.listener_port

  default_actions {
    type = var.alb_listener_config.default_action_type
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.server_group_a.id
      }
    }
  }
}

resource "alicloud_alb_listener" "listener_b" {
  provider          = alicloud.region_B
  load_balancer_id  = alicloud_alb_load_balancer.alb_b.id
  listener_protocol = var.alb_listener_config.listener_protocol
  listener_port     = var.alb_listener_config.listener_port

  default_actions {
    type = var.alb_listener_config.default_action_type
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.server_group_b.id
      }
    }
  }
}

# CEN instance
resource "alicloud_cen_instance" "cen" {
  cen_instance_name = var.cen_instance_name
}

# CEN transit router
resource "alicloud_cen_transit_router" "tr_a" {
  provider   = alicloud.region_A
  cen_id     = alicloud_cen_instance.cen.id
  depends_on = [alicloud_cen_instance.cen]
}

resource "alicloud_cen_transit_router" "tr_b" {
  provider   = alicloud.region_B
  cen_id     = alicloud_cen_instance.cen.id
  depends_on = [alicloud_cen_instance.cen]
}

# CEN transit router VPC attachments
resource "alicloud_cen_transit_router_vpc_attachment" "vpc_att_a" {
  provider                           = alicloud.region_A
  transit_router_vpc_attachment_name = var.cen_region_a_vpc_attachment_name
  cen_id                             = alicloud_cen_instance.cen.id
  transit_router_id                  = alicloud_cen_transit_router.tr_a.transit_router_id
  vpc_id                             = alicloud_vpc.vpc_a.id

  dynamic "zone_mappings" {
    for_each = alicloud_vswitch.region_a_vswitches
    content {
      zone_id    = zone_mappings.value.zone_id
      vswitch_id = zone_mappings.value.id
    }
  }
}

resource "alicloud_cen_transit_router_vpc_attachment" "vpc_att_b" {
  provider                           = alicloud.region_B
  transit_router_vpc_attachment_name = var.cen_region_b_vpc_attachment_name
  cen_id                             = alicloud_cen_instance.cen.id
  transit_router_id                  = alicloud_cen_transit_router.tr_b.transit_router_id
  vpc_id                             = alicloud_vpc.vpc_b.id

  dynamic "zone_mappings" {
    for_each = alicloud_vswitch.region_b_vswitches
    content {
      zone_id    = zone_mappings.value.zone_id
      vswitch_id = zone_mappings.value.id
    }
  }
}

# CEN transit router route tables
resource "alicloud_cen_transit_router_route_table" "route_table_a" {
  provider          = alicloud.region_A
  transit_router_id = alicloud_cen_transit_router.tr_a.transit_router_id
}

resource "alicloud_cen_transit_router_route_table" "route_table_b" {
  provider          = alicloud.region_B
  transit_router_id = alicloud_cen_transit_router.tr_b.transit_router_id
}

# CEN transit router route entries
resource "alicloud_cen_transit_router_route_entry" "route_entry_a" {
  for_each = var.region_a_cen_route_entries

  provider                                          = alicloud.region_A
  transit_router_route_table_id                     = alicloud_cen_transit_router_route_table.route_table_a.transit_router_route_table_id
  transit_router_route_entry_destination_cidr_block = each.value.destination_cidr_block
  transit_router_route_entry_next_hop_type          = each.value.next_hop_type
  transit_router_route_entry_next_hop_id            = alicloud_cen_transit_router_vpc_attachment.vpc_att_a.transit_router_attachment_id
}

resource "alicloud_cen_transit_router_route_entry" "route_entry_b" {
  for_each = var.region_b_cen_route_entries

  provider                                          = alicloud.region_B
  transit_router_route_table_id                     = alicloud_cen_transit_router_route_table.route_table_b.transit_router_route_table_id
  transit_router_route_entry_destination_cidr_block = each.value.destination_cidr_block
  transit_router_route_entry_next_hop_type          = each.value.next_hop_type
  transit_router_route_entry_next_hop_id            = alicloud_cen_transit_router_vpc_attachment.vpc_att_b.transit_router_attachment_id
}

# CEN transit router route table associations
resource "alicloud_cen_transit_router_route_table_association" "association_a" {
  provider                      = alicloud.region_A
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.route_table_a.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.vpc_att_a.transit_router_attachment_id
}

resource "alicloud_cen_transit_router_route_table_association" "association_b" {
  provider                      = alicloud.region_B
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.route_table_b.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.vpc_att_b.transit_router_attachment_id
}

# CEN transit router peer attachment
resource "alicloud_cen_transit_router_peer_attachment" "peer_attachment" {
  provider                      = alicloud.region_B
  cen_id                        = alicloud_cen_instance.cen.id
  transit_router_id             = alicloud_cen_transit_router.tr_b.transit_router_id
  peer_transit_router_region_id = data.alicloud_regions.region_a.regions[0].id
  peer_transit_router_id        = alicloud_cen_transit_router.tr_a.transit_router_id
  bandwidth_type                = var.cen_peer_bandwidth_type
  bandwidth                     = var.cen_peer_bandwidth
  auto_publish_route_enabled    = var.cen_peer_auto_publish_route
}

# CEN transit router route table associations for peer attachment
resource "alicloud_cen_transit_router_route_table_association" "association_c" {
  provider                      = alicloud.region_A
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.route_table_a.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
}

resource "alicloud_cen_transit_router_route_table_association" "association_d" {
  provider                      = alicloud.region_B
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.route_table_b.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
}

# CEN transit router route table propagations
resource "alicloud_cen_transit_router_route_table_propagation" "propagation_c" {
  provider                      = alicloud.region_A
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.route_table_a.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
}

resource "alicloud_cen_transit_router_route_table_propagation" "propagation_d" {
  provider                      = alicloud.region_B
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.route_table_b.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
}

# DTS instance for database synchronization
resource "alicloud_dts_instance" "default" {
  provider                         = alicloud.region_A
  type                             = var.dts_config.type
  payment_type                     = var.dts_config.payment_type
  instance_class                   = var.dts_config.instance_class
  source_endpoint_engine_name      = var.dts_config.source_endpoint_engine_name
  source_region                    = var.dts_config.source_region
  destination_endpoint_engine_name = var.dts_config.destination_endpoint_engine_name
  destination_region               = var.dts_config.destination_region
}
