output "data_id" {
  value       = module.efs.access_points["data"].id
}

output "apps_id" {
  value       = module.efs.access_points["apps"].id
}
output "config_points" {
  value       = module.efs.access_points["config"].id
}

output "efs_id" {
  value       = module.efs.id
}
