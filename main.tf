#-------------------------------------------------------------------
# CREATE IAM USER, GROUP AND GROUP POLICY
#-------------------------------------------------------------------

resource "aws_iam_user" "user" {
  name = "admin"
  path = var.path

  tags = {
    tag-key = "terraform"
  }
}

resource "aws_iam_access_key" "key" {
  user = aws_iam_user.user.name
}

resource "aws_iam_group" "admins" {
  name = "admins"
  path = var.path
}

resource "aws_iam_group_membership" "team" {
  name = "tf-admin-group"

  users = [
    aws_iam_user.user.name
  ]

  group = aws_iam_group.admins.name
}

resource "aws_iam_group_policy" "admins_policy" {
  name  = "admins_group_policy"
  group = ws_iam_group.admins.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "Allow"
        Effect = "*"
        Resource = "*"
      },
    ]
  })
}

#-------------------------------------------------------------------
# CREATE BUCKET
#-------------------------------------------------------------------

resource "aws_s3_bucket" "dev" {
  bucket = "terraform-dev"
  acl    = "private"
  tags = {
    Name        = "xpto-dev"
    Environment = "dev"
  }
}

#-------------------------------------------------------------------
# CREATE VPC
#-------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block       = var.cdirs_remote_access
  instance_tenancy = "default"

  tags = {
    Name = "vpc-xpto"
  }
}

#-------------------------------------------------------------------
# CREATE A SECURITY GROUP
#-------------------------------------------------------------------

resource "aws_security_group" "access-ssh" {
  name          = "access-ssh"
  ingress {
    from_port   = 22
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = aws_vpc.main.cidr_block
  }
  tags = {
    Name = "ssh"
  }
}

resource "aws_security_group" "access-http" {
  name          = "access-http"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = aws_vpc.main.cidr_block
  }
  tags = {
    Name = "http"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_tls"
  }
}

#-------------------------------------------------------------------
# CREATE A KEY PAIR AND INSTANCE
#-------------------------------------------------------------------

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = var.public_key
}

resource "aws_instance" "dev" {
  count                  = 1
  ami                    = var.amis["us-east-1"]
  instance_type          = var.instance_type
  key_name               = aws_key_pair.admin.name

  tags  = {
    Name = "instance-dev-${count.index}"
  }

  vpc_security_group_ids = [aws_security_group.access-ssh.id, aws_security_group.access-http.id, aws_security_group.allow_tls.id]
  depends_on             = [aws_s3_bucket.dev]
}

#-------------------------------------------------------------------
# CREATE APPLICATION LOAD BALANCER 
#-------------------------------------------------------------------

resource "aws_lb" "dev" {
  name               = var.name_load_balancer
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.access-ssh.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  ip_address_type    = "ipv4"

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.dev.bucket
    prefix  = "dev-lb"
    enabled = true
  }

  tags = {
    Environment = "dev"
  }
}

#-------------------------------------------------------------------
# CREATE A TARGET GROUP
#-------------------------------------------------------------------

resource "aws_lb_target_group" "dev_http" {
  name     = var.name_target
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "dev_https" {
  name     = var.name_targe_https
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.main.id
}

#-------------------------------------------------------------------
# CREATE AUTOSCALING GROUP
#-------------------------------------------------------------------

resource "aws_placement_group" "dev" {
  name     = "dev"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "bar" {
  name                      = var.name_autoscaling
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  placement_group           = aws_placement_group.dev.id
  launch_configuration      = aws_launch_configuration.foobar.name
  vpc_zone_identifier       = [for subnet in aws_subnet.public : subnet.id]

  tag {
    key                 = "environment"
    value               = "dev"
    propagate_at_launch = true
  }

  timeouts {
    delete = "3m"
  }
}