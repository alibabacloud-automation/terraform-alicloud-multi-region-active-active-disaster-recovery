terraform {
  required_version = ">= 1.0"

  required_providers {
    alicloud = {
      source                = "aliyun/alicloud"
      version               = ">= 1.210.0"
      configuration_aliases = [alicloud.region_A, alicloud.region_B]
    }
  }
}
