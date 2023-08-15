locals {
  region = var.aws_region
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

module "efs" {
  source = "terraform-aws-modules/efs/aws"

  # File system
  name           = "${var.project_name}-efs"
  encrypted      = true

  performance_mode                = "generalPurpose"
  throughput_mode                 = "bursting"

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"  
  }

  # File system policy
  attach_policy                      = false

  # Mount targets / security group
  mount_targets              = { for k, v in zipmap(local.azs, module.vpc.private_subnets) : k => { subnet_id = v } }
  security_group_description = "EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC subnets"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }
  # Access point(s)
  access_points = {
    apps = {
      root_directory = {
        path = "/apps"
        creation_info = {
          owner_gid   = 33
          owner_uid   = 33
          permissions = "0755"
        }
      }
    }

    config = {
      root_directory = {
        path = "/config"
        creation_info = {
          owner_gid   = 33
          owner_uid   = 33
          permissions = "0755"
        }
      }
    }

    data = {
      root_directory = {
        path = "/data"
        creation_info = {
          owner_gid   = 33
          owner_uid   = 33
          permissions = "0755"
        }
      }
    }
  }

  # Backup policy
  enable_backup_policy = true

}