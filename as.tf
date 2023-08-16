data "aws_ami" "api" {
  most_recent = true
  filter {
    name   = "name"
    values = ["${var.project_name}-app"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners     = ["${var.owner}"]
  depends_on = [aws_ami_from_instance.ami]
}

resource "aws_launch_template" "lt" {
  name_prefix   = "lt-"
  image_id      = data.aws_ami.api.id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.sg_ec2.id]
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "asg-${var.project_name}"
  min_size                  = 1
  desired_capacity          = 1
  max_size                  = 6
  force_delete              = true
  health_check_grace_period = 240
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.this.arn]
  vpc_zone_identifier       = module.vpc.public_subnets

  launch_template {
    id      = aws_launch_template.lt.id
    version = aws_launch_template.lt.latest_version
  }
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

}

resource "aws_autoscaling_policy" "policy_up" {
  name                   = "${var.project_name}_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_up" {
  alarm_name          = "${var.project_name}_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Esta métrica monitora a utilização da CPU da instância do EC2"
  alarm_actions     = [aws_autoscaling_policy.policy_up.arn]
}

resource "aws_autoscaling_policy" "policy_down" {
  name                   = "${var.project_name}_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_down" {
  alarm_name          = "${var.project_name}_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Esta métrica monitora a utilização da CPU da instância do EC2"
  alarm_actions     = [aws_autoscaling_policy.policy_down.arn]
}