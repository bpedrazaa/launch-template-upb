# SECURITY GROUPS
resource "aws_security_group" "upb_load_balancer_sg" { 
  name        = "upb-load-balancer-sg"
  vpc_id      = data.aws_ssm_parameter.vpc_id_parameter.value

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  tags = {
    Name = "upb-load-balancer-sg"
  }
}

resource "aws_security_group" "upb_instance_sg" {
  name        = "upb-instance-sg"
  vpc_id      = data.aws_ssm_parameter.vpc_id_parameter.value

  ingress {
    description      = "http traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "upb-instance-sg"
  }
}

# LAUNCH TEMPLATE
resource "aws_launch_template" "upb-lt" {
  name = "upb-lt"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 10
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.upb_instance_sg.id}"]
  }
  
  disable_api_termination = true

  image_id = "ami-00068cd7555f543d5"

  instance_type = "t2.micro"

  key_name = "upb-lt"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "upb-lt"
    }
  }
  user_data = filebase64("${path.module}/init.sh")
}