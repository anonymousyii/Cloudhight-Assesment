resource "aws_lb" "main_elb" {
  name               = "main-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = aws_subnet.public[*].id
  tags = {
    Environment = "${var.env_code}-loadbalancer-my-sg"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "tf-main-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.cloudheight_vpc.id 

  health_check {
    enabled             = true
    healthy_threshold   = 5 
    unhealthy_threshold = 2
    port                = "traffic-port"
    path                = "/"
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}