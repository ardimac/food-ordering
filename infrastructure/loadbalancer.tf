resource "aws_lb" "testapp-load-balancer" {
  name               = "testapp-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-public-traffic.id]
  subnets            = [
    aws_subnet.public_subnet-a.id,
    aws_subnet.public_subnet-b.id
  ]

  #enable_deletion_protection = true

  tags = {
    Name = "testapp-load-balancer"
  }
}

resource "aws_lb_target_group" "testapp-target-group" {
  name     = "testapp-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}


resource "aws_lb_listener" "testapp-listener" {
  load_balancer_arn = aws_lb.testapp-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.testapp-target-group.arn
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.testapp-target-group.arn
  target_id        = aws_autoscaling_group.main.id
  port             = 80
}
