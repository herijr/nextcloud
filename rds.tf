resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-group"
  subnet_ids = module.vpc.private_subnets
  tags = {
    Name = "mysql-${var.project_name}"
  }
}

resource "aws_db_instance" "this" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.33"
  identifier           = "database-${var.project_name}"
  instance_class       = "db.t2.micro"
  db_name              = "db${var.project_name}"
  username             = "admin"
  password             = "senha1234"
  parameter_group_name = "default.mysql8.0"
  availability_zone    = "${var.aws_region}a"
  skip_final_snapshot  = true

  db_subnet_group_name   = aws_db_subnet_group.default.id
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
}