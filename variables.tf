variable "aws_region" {
  type        = string
  description = ""
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = ""
  default     = "nextcloud"
}

variable "ec2_key" {
  type        = string
  description = ""
  default     = "aws01"
}

variable "ec2_instance_type" {
  type        = string
  description = ""
  default     = "t4g.small"
}

variable "arch" {
  type        = string
  description = ""
  default     = "arm64"
}

variable "owner" {
  type        = string
  description = ""
  default     = "432627114264"
}