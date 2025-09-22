

resource "aws_lb_target_group" "frontend_tg" {
  name     = "project2-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  # Health check for your front-end application
  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "project2-frontend-tg"
  }
}

resource "aws_lb" "project2_alb" {
  name               = "project2-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  # The ALB must be in the public subnets
  subnets = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "project2-alb"
  }
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.project2_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "frontend_tg_attachment" {
  count            = 2 # One attachment per frontend EC2 instance
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = aws_instance.frontend_servers[count.index].id
  port             = 80
}

