data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Allow traffic from app layer"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.db.id]
  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y postgresql postgresql-contrib
              systemctl enable postgresql
              systemctl start postgresql
              
              # Set postgres password and create database
              sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'password';"
              sudo -u postgres psql -c "CREATE DATABASE user_management;"

              # Basic hardening and configuration for remote access (restricted to VPC)
              sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/*/main/postgresql.conf
              echo "host all all ${var.vpc_cidr} md5" >> /etc/postgresql/*/main/pg_hba.conf
              systemctl restart postgresql
              EOF

  tags = {
    Name = "${var.project_name}-db"
  }
}
