resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project_name}-cache-subnet"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_cluster" "this" {
  cluster_id           = "redis-${var.project_name}"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  security_group_ids   = [aws_security_group.sg_redis.id]
  subnet_group_name    = aws_elasticache_subnet_group.this.name
}