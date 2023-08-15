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

resource "aws_instance" "nextcloud" {
  instance_type               = "t4g.small"
  ami                         = data.aws_ami.ubuntu.id
  user_data                   = data.template_file.script.rendered
  vpc_security_group_ids      = [aws_security_group.sg_ec2.id]
  subnet_id                   = element(module.vpc.public_subnets, 0)
  key_name                    = "aws01"
  associate_public_ip_address = true
  tags = {
    Name = "nextcloud"
  }
}