resource "aws_lb" "this" {
  load_balancer_type = "application"
  name               = "${var.project_name}-alb"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = module.vpc.public_subnets
  tags = merge(
    local.tags,
    {
      Name = "${var.project_name}-alb"
    }
  )
}


resource "aws_lb_target_group" "this" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"

  tags = merge(
    local.tags,
    {
      Name = "${var.project_name}-tg"
    }
  )
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    healthy_threshold = 2
    path              = "/robots.txt"
    matcher           = "200"
  }

  stickiness {
    cookie_duration = 3600
    enabled         = true
    type            = "lb_cookie"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}