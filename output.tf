output "public_ip" {
  value       = aws_instance.ec2.public_ip
}

output "load_balancer_dns" {
  value       = aws_lb.this.dns_name
}
output "rds_endpoint" {
  value       = aws_db_instance.this.endpoint
}