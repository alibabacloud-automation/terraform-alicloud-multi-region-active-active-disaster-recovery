output "region_a_vpc_id" {
  description = "ID of the VPC in region 1"
  value       = module.disaster_recovery.region_a_vpc_id
}

output "region_b_vpc_id" {
  description = "ID of the VPC in region 2"
  value       = module.disaster_recovery.region_b_vpc_id
}

output "region_a_alb_dns_name" {
  description = "DNS name of the ALB in region 1"
  value       = module.disaster_recovery.region_a_alb_dns_name
}

output "region_b_alb_dns_name" {
  description = "DNS name of the ALB in region 2"
  value       = module.disaster_recovery.region_b_alb_dns_name
}

output "cen_instance_id" {
  description = "ID of the CEN instance"
  value       = module.disaster_recovery.cen_instance_id
}
