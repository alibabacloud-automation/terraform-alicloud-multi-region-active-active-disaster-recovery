# Multi-region active-active disaster recovery example
# This example demonstrates the complete setup across two regions

provider "alicloud" {
  alias  = "region_A"
  region = "cn-shanghai"
}

provider "alicloud" {
  alias  = "region_B"
  region = "cn-beijing"
}

module "disaster_recovery" {
  source = "../.."

  providers = {
    alicloud.region_A = alicloud.region_A
    alicloud.region_B = alicloud.region_B
  }

  # VPC configuration for region A
  region_a_vpc_config = {
    cidr_block = "10.0.0.0/16"
  }

  # VPC configuration for region B
  region_b_vpc_config = {
    cidr_block = "172.16.0.0/16"
  }

  # Region 1 vswitch configurations
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

  # Region 2 vswitch configurations
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

  region_a_security_group_rules = {
    allow_ssh = {
      type        = "ingress"
      ip_protocol = "all"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "22/22"
      priority    = 1
      cidr_ip     = "10.0.0.0/16"
    }
  }

  region_b_security_group_rules = {
    allow_ssh = {
      type        = "ingress"
      ip_protocol = "all"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "22/22"
      priority    = 1
      cidr_ip     = "172.16.0.0/16"
    }
  }

  # Route entries for region 1
  region_a_route_entries = {
    to_region2_vsw1 = {
      destination_cidrblock = "172.16.1.0/24"
      nexthop_type          = "Attachment"
    }
    to_region2_vsw2 = {
      destination_cidrblock = "172.16.2.0/24"
      nexthop_type          = "Attachment"
    }
  }

  # Route entries for region 2
  region_b_route_entries = {
    to_region1_vsw1 = {
      destination_cidrblock = "10.0.1.0/24"
      nexthop_type          = "Attachment"
    }
    to_region1_vsw2 = {
      destination_cidrblock = "10.0.2.0/24"
      nexthop_type          = "Attachment"
    }
  }

  # ECS instances for region 1
  region_a_ecs_instances = {
    app001 = {
      instance_name        = "APP001"
      instance_type        = "ecs.g8i.large"
      vswitch_key          = "vsw1"
      image_id             = "aliyun_3_x64_20G_alibase_20250629.vhd"
      system_disk_category = "cloud_essd"
      instance_charge_type = "PostPaid"
    }
    app002 = {
      instance_name        = "APP002"
      instance_type        = "ecs.g8i.large"
      vswitch_key          = "vsw2"
      image_id             = "aliyun_3_x64_20G_alibase_20250629.vhd"
      system_disk_category = "cloud_essd"
      instance_charge_type = "PostPaid"
    }
  }

  # ECS instances for region 2
  region_b_ecs_instances = {
    app003 = {
      instance_name        = "APP003"
      instance_type        = "ecs.g7.large"
      vswitch_key          = "vsw1"
      image_id             = "aliyun_3_x64_20G_alibase_20250629.vhd"
      system_disk_category = "cloud_essd"
      instance_charge_type = "PostPaid"
    }
    app004 = {
      instance_name        = "APP004"
      instance_type        = "ecs.g7.large"
      vswitch_key          = "vsw2"
      image_id             = "aliyun_3_x64_20G_alibase_20250629.vhd"
      system_disk_category = "cloud_essd"
      instance_charge_type = "PostPaid"
    }
  }

  # Passwords
  ecs_instance_password = var.ecs_instance_password
  db_password           = var.db_password

  # CEN route entries for region 1
  region_a_cen_route_entries = {
    route1 = {
      destination_cidr_block = "10.0.1.0/24"
      next_hop_type          = "Attachment"
    }
    route2 = {
      destination_cidr_block = "10.0.2.0/24"
      next_hop_type          = "Attachment"
    }
  }

  # CEN route entries for region 2
  region_b_cen_route_entries = {
    route1 = {
      destination_cidr_block = "172.16.1.0/24"
      next_hop_type          = "Attachment"
    }
    route2 = {
      destination_cidr_block = "172.16.2.0/24"
      next_hop_type          = "Attachment"
    }
  }

  # DTS configuration
  dts_config = {
    type                             = "sync"
    payment_type                     = "PayAsYouGo"
    instance_class                   = "large"
    source_endpoint_engine_name      = "MySQL"
    source_region                    = "cn-shanghai"
    destination_endpoint_engine_name = "MySQL"
    destination_region               = "cn-beijing"
  }
}
