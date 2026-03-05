# VPC outputs
output "region_a_vpc_id" {
  description = "ID of the VPC in region 1"
  value       = alicloud_vpc.vpc_a.id
}

output "region_b_vpc_id" {
  description = "ID of the VPC in region 2"
  value       = alicloud_vpc.vpc_b.id
}

output "region_a_vswitch_ids" {
  description = "Map of vswitch IDs in region 1"
  value = {
    for key, vswitch in alicloud_vswitch.region_a_vswitches : key => vswitch.id
  }
}

output "region_b_vswitch_ids" {
  description = "Map of vswitch IDs in region 2"
  value = {
    for key, vswitch in alicloud_vswitch.region_b_vswitches : key => vswitch.id
  }
}

# Security group outputs
output "region_a_security_group_id" {
  description = "ID of the security group in region 1"
  value       = alicloud_security_group.group_a.id
}

output "region_b_security_group_id" {
  description = "ID of the security group in region 2"
  value       = alicloud_security_group.group_b.id
}

# ECS instance outputs
output "region_a_instance_ids" {
  description = "Map of ECS instance IDs in region 1"
  value = {
    for key, instance in alicloud_instance.region_a_instances : key => instance.id
  }
}

output "region_b_instance_ids" {
  description = "Map of ECS instance IDs in region 2"
  value = {
    for key, instance in alicloud_instance.region_b_instances : key => instance.id
  }
}

output "region_a_instance_private_ips" {
  description = "Map of ECS instance private IPs in region 1"
  value = {
    for key, instance in alicloud_instance.region_a_instances : key => instance.private_ip
  }
}

output "region_b_instance_private_ips" {
  description = "Map of ECS instance private IPs in region 2"
  value = {
    for key, instance in alicloud_instance.region_b_instances : key => instance.private_ip
  }
}

# PolarDB outputs
output "region_a_polardb_cluster_id" {
  description = "ID of the PolarDB cluster in region 1"
  value       = alicloud_polardb_cluster.polardb_a.id
}

output "region_b_polardb_cluster_id" {
  description = "ID of the PolarDB cluster in region 2"
  value       = alicloud_polardb_cluster.polardb_b.id
}

output "region_a_polardb_connection_string" {
  description = "Connection string of the PolarDB cluster in region 1"
  value       = alicloud_polardb_cluster.polardb_a.connection_string
}

output "region_b_polardb_connection_string" {
  description = "Connection string of the PolarDB cluster in region 2"
  value       = alicloud_polardb_cluster.polardb_b.connection_string
}

# ALB outputs
output "region_a_alb_id" {
  description = "ID of the Application Load Balancer in region 1"
  value       = alicloud_alb_load_balancer.alb_a.id
}

output "region_b_alb_id" {
  description = "ID of the Application Load Balancer in region 2"
  value       = alicloud_alb_load_balancer.alb_b.id
}

output "region_a_alb_dns_name" {
  description = "DNS name of the Application Load Balancer in region 1"
  value       = alicloud_alb_load_balancer.alb_a.dns_name
}

output "region_b_alb_dns_name" {
  description = "DNS name of the Application Load Balancer in region 2"
  value       = alicloud_alb_load_balancer.alb_b.dns_name
}

output "region_a_alb_status" {
  description = "Status of the Application Load Balancer in region 1"
  value       = alicloud_alb_load_balancer.alb_a.status
}

output "region_b_alb_status" {
  description = "Status of the Application Load Balancer in region 2"
  value       = alicloud_alb_load_balancer.alb_b.status
}

# CEN outputs
output "cen_instance_id" {
  description = "ID of the CEN instance"
  value       = alicloud_cen_instance.cen.id
}

output "region_a_transit_router_id" {
  description = "ID of the CEN transit router in region 1"
  value       = alicloud_cen_transit_router.tr_a.transit_router_id
}

output "region_b_transit_router_id" {
  description = "ID of the CEN transit router in region 2"
  value       = alicloud_cen_transit_router.tr_b.transit_router_id
}

output "region_a_vpc_attachment_id" {
  description = "ID of the CEN VPC attachment in region 1"
  value       = alicloud_cen_transit_router_vpc_attachment.vpc_att_a.transit_router_attachment_id
}

output "region_b_vpc_attachment_id" {
  description = "ID of the CEN VPC attachment in region 2"
  value       = alicloud_cen_transit_router_vpc_attachment.vpc_att_b.transit_router_attachment_id
}

# DTS outputs
output "dts_instance_id" {
  description = "ID of the DTS instance for database synchronization"
  value       = alicloud_dts_instance.default.id
}
