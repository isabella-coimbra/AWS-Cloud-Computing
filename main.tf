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
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = aws_vpc.main.cidr_block
  }
  tags = {
    Name = "ssh"
  }
}

#-------------------------------------------------------------------
# CREATE AN INSTANCE
#-------------------------------------------------------------------

resource "aws_instance" "dev" {
  count                  = 3
  ami                    = var.amis["us-east-1"]
  instance_type          = var.instance_type
  key_name               = "terraform-aws"

  tags  = {
    Name = "instance-dev-${count.index}"
  }

  vpc_security_group_ids = aws_security_group.access-ssh.id
  depends_on             = [aws_s3_bucket.dev, aws_dynamodb_table.dynamodb-dev]
}
