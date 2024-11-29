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
  image_id        = "ami-0b037f98da520a29a" # Replace with your desired AMI
  instance_type   = "t2.micro"
  key_name        = "testapp"
  vpc_security_group_ids = [aws_security_group.sg-private-application.id]
  user_data = filebase64("userdata.sh")
}

# Create emergency bastion
resource "aws_instance" "bastion" {
  ami                    = "ami-047126e50991d067b"
  instance_type          = "t2.micro"
  key_name               = "testapp"
  subnet_id              = aws_subnet.public_subnet-a.id
  vpc_security_group_ids = [aws_security_group.sg-public-traffic.id]
  tags = {
    Name = "bastion"
  }
  associate_public_ip_address = "true"
}

# Create jenkins
resource "aws_instance" "jenkins" {
  ami                    = "ami-0b25a263e0c4729cb"
  instance_type          = "t2.medium"
  key_name               = "testapp"
  subnet_id              = aws_subnet.public_subnet-b.id
  vpc_security_group_ids = [aws_security_group.sg-public-traffic.id]
  tags = {
    Name = "jenkins"
  }
  associate_public_ip_address = "true"
}

# Create postgres
resource "aws_instance" "postgres" {
  ami                    = "ami-059edcde4b66b8e2e"
  instance_type          = "t2.micro"
  key_name               = "testapp"
  subnet_id              = aws_subnet.private_subnet-a.id
  vpc_security_group_ids = [aws_security_group.sg-private-application.id]
  tags = {
    Name = "postgres"
  }
}

