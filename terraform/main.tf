# VPC作成
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}
# Public Subnet作成
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-1a"
  }
}
# Public Subnet作成（1c）
resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1c_cidr
  availability_zone       = var.availability_zone_1c
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-1c"
  }
}
# Private Subnet作成（1a）
resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_1a_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet-1a"
  }
}
# Private Subnet作成（1c）
resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_1c_cidr
  availability_zone       = var.availability_zone_1c
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet-1c"
  }
}
# Internet Gateway作成
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-internet-gateway"
  }
}

# Public Route Table作成
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-route-table"
  }
}
# Public Route作成
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
# Public SubnetとRoute Tableを関連付け
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}
# Public Subnet 1c と Public Route Tableを関連付け
resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}
# Private Route Table作成
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-route-table"
  }
}
# Private Subnet用 Default Route作成
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
# Private Subnet 1a と Private Route Tableを関連付け
resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}
# Private Subnet 1c と Private Route Tableを関連付け
resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private.id
}
# Application Load Balancer作成
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"

  # ALB用Security Groupを紐付ける
  security_groups = [aws_security_group.alb_sg.id]

  # ALBはPublic Subnet 2つに配置する
  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]

  tags = {
    Name = "${var.project_name}-alb"
  }
}
# ALBの転送先となるTarget Groupを作成
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # EC2インスタンスをターゲットとして登録する
  target_type = "instance"

  # ALBがEC2/nginxの正常性を確認する設定
  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}
# ALB Listener作成
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  # 受け取ったHTTPリクエストをTarget Groupへ転送する
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
# Private EC2をTarget Groupに登録
resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.docker_host.id
  port             = 80
}
# ALB用 Security Group作成
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}
# ALBへのHTTP接続許可
resource "aws_security_group_rule" "alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}
# ALBから外向き通信を許可
resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}
# EC2用 Security Group作成
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-SG"
  description = "Security group for EC2 Docker hands-on"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-SG"
  }
}
# EC2へのHTTP接続許可（ALBからのみ）
resource "aws_security_group_rule" "ec2_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ec2_sg.id
}
# EC2から外向き通信を許可
resource "aws_security_group_rule" "ec2_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}
# EC2作成
resource "aws_instance" "docker_host" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private_1a.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_instance_profile.name

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "${var.project_name}-private-docker-instance"
  }
}
# EC2がSSMを利用するためのIAM Role
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_name}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-ssm-role"
  }
}
# SSM接続に必要なAWS管理ポリシーを付与
resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# EC2へIAM Roleを紐付けるためのInstance Profile
resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
  name = "${var.project_name}-ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}
# NAT Gateway用 Elastic IP作成
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}
# NAT Gateway作成
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.main]
}
