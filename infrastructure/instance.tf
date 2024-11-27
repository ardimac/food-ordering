# Create an Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                      = "testapp"
  vpc_zone_identifier       = [aws_subnet.private_subnet-a.id, aws_subnet.private_subnet-b.id]
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  health_check_type         = "EC2"
  target_group_arns         = [aws_lb_target_group.testapp-target-group.arn]
}

# Create a Launch Template
resource "aws_launch_template" "main" {
  name            = "app-template"
  image_id        = "ami-00c0b98389042f9d5" # Replace with your desired AMI
  instance_type   = "t2.micro"
  key_name        = "testapp"
  vpc_security_group_ids = [aws_security_group.sg-private-application.id]
  user_data = file("install_nginx.sh")
}
