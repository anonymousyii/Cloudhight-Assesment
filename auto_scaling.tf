data "aws_ami" "ubuntu_22_04_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_configuration" "main" {
  name_prefix          = "${var.env_code}-launch-config"
  image_id             = data.aws_ami.ubuntu_22_04_ami.id
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.private.id]
  key_name = "aws-terraform"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "main" {
  name                 = var.env_code
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = aws_subnet.private[*].id
  target_group_arns    = [aws_lb_target_group.main.arn]

  tag {
    key                 = "Name"
    value               = "${var.env_code}-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}