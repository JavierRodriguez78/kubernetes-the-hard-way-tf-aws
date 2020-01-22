terraform {
  required_version = "0.12.12"

  backend "s3" {
    bucket         = "hf-sandbox-tfstate-bucket"
    encrypt        = true
    key            = "kubernetes-the-hard-way/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "sandbox-tfstate-lock-table"
    profile        = "kube-the-hard-way"
  }
}

provider "aws" {
  version = "2.33.0"
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_key_pair" "kube_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# --- Networking ---

## -- VPC --
resource "aws_vpc" "kube_vpc" {
  cidr_block           = "10.240.0.0/24"
  enable_dns_hostnames = true
}

## -- Internet Gateway --
resource "aws_internet_gateway" "kube_igw" {

  vpc_id = aws_vpc.kube_vpc.id

  tags = {
    Name = "kube_igw"
  }
}

## -- Public routing table
resource "aws_route_table" "kube_public_rt" {
  vpc_id = aws_vpc.kube_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kube_igw.id
  }

  tags = {
    Name = "kube_public_rt"
  }
}

## -- Public subnets --
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "kube_public_subnet" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id                  = aws_vpc.kube_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.kube_vpc.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "kube_public_${count.index}_sn"
  }
}
## -- Security groups --
resource "aws_security_group" "kube_web_open_sg" {
  vpc_id      = aws_vpc.kube_vpc.id
  description = "Security group for open to the internet"
  name        = "kube_web_open_sg"

  #SSH 
  ingress {
    description = "Incoming ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #HTTP
  ingress {
    description = "Standard http incoming"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTPS
  ingress {
    description = "Standard https incoming"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ETCD port opening"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes config"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ports and protocols to go out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
## -- Subnet and Rout tabel association
resource "aws_route_table_association" "kube_public_assoc" {
  count          = length(aws_subnet.kube_public_subnet)
  subnet_id      = aws_subnet.kube_public_subnet[count.index].id
  route_table_id = aws_route_table.kube_public_rt.id
}

# --- Instances ---
resource "aws_instance" "kube_controller" {
  count = length(aws_subnet.kube_public_subnet)

  instance_type = var.instance_type
  ami           = var.ami_type

  tags = {
    Name = "kube_controller_${count.index}_instance"
  }
  user_data              = "name=controller-${count.index}"
  key_name               = aws_key_pair.kube_auth.id
  vpc_security_group_ids = [aws_security_group.kube_web_open_sg.id]
  subnet_id              = aws_subnet.kube_public_subnet[count.index].id
}

resource "aws_instance" "kube_worker" {
  count = length(aws_subnet.kube_public_subnet)

  instance_type = var.instance_type
  ami           = var.ami_type

  tags = {
    Name = "kube_worker_${count.index}_instance"
  }

  user_data = "name=worker-${count.index}|pod-cidr=10.200.${count.index}.0/24"

  key_name               = aws_key_pair.kube_auth.id
  vpc_security_group_ids = [aws_security_group.kube_web_open_sg.id]
  subnet_id              = aws_subnet.kube_public_subnet[count.index].id
}

resource "aws_lb" "kube_loadbalancer" {
  name               = "kube-loadbalancer"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.kube_public_subnet : subnet.id]

  enable_deletion_protection = false

  depends_on = [aws_instance.kube_controller]
}

resource "aws_lb_target_group" "kube_controller_target_group" {
  name     = "kube-controller-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_vpc.kube_vpc.id
}

resource "aws_lb_target_group_attachment" "hf_lb_instance_attachment" {
  count = length(aws_instance.kube_controller)

  target_group_arn = aws_lb_target_group.kube_controller_target_group.arn
  target_id        = aws_instance.kube_controller[count.index].id
  port             = 6443
}

resource "aws_lb_listener" "kube_port443_listener" {
  load_balancer_arn = aws_lb.kube_loadbalancer.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kube_controller_target_group.arn
  }
}