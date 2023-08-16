data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "template_file" "script" {
  template = file("userdata.sh")
  vars = {
    efs-id = module.efs.id
    apps = module.efs.access_points["apps"].id
    config = module.efs.access_points["config"].id
    data = module.efs.access_points["data"].id
  }
}

resource "aws_instance" "ec2" {
  instance_type               = var.ec2_instance_type
  ami                         = data.aws_ami.ubuntu.id
  user_data                   = data.template_file.script.rendered
  vpc_security_group_ids      = [aws_security_group.sg_ec2.id]
  subnet_id                   = element(module.vpc.public_subnets, 0)
  key_name                    = var.ec2_key
  associate_public_ip_address = true
  tags = {
    Name = "${var.project_name}"
  }
}

resource "time_sleep" "wait_seconds" {
  depends_on      = [aws_instance.ec2]
  create_duration = "900s"
}

resource "aws_ami_from_instance" "ami" {
  name                    = "${var.project_name}-app"
  source_instance_id      = aws_instance.ec2.id
  snapshot_without_reboot = true
  tags = {
    Name = "${var.project_name}-app"
  }

  depends_on = [time_sleep.wait_seconds]
}