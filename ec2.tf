resource "aws_security_group" "alb_sg" {
  name        = "project2-alb-sg"
  description = "Allows HTTP/S traffic from the internet to the ALB"
  vpc_id      = module.vpc.vpc_id

  # Inbound rule for HTTP traffic from anywhere on the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule for HTTPS traffic from anywhere on the internet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project2-alb-sg"
  }
}

resource "aws_security_group" "frontend_sg" {
  name        = "project2-frontend-sg"
  description = "Allows inbound traffic from the ALB"
  vpc_id      = module.vpc.vpc_id

  # Allow traffic from the ALB security group only
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project2-frontend-sg"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "project2-backend-sg"
  description = "Allows inbound traffic from the frontend tier"
  vpc_id      = module.vpc.vpc_id

  # Allow inbound traffic on the backend app port (e.g., 8080)
  # ONLY from the frontend's security group.
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project2-backend-sg"
  }
}

# variable "ec2_sg-list" {
#     default = []
  
# }

# variable "ec2-names" {
#     default =[]
  
# }

resource "aws_instance" "frontend_servers" {
  count         = 2
  ami           = "ami-01b6d88af12965bb6" 
  instance_type = "t2.micro"

  subnet_id = module.vpc.private_subnets[count.index]

  # Attach the frontend security group
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  tags = {
    Name = "project2-Frontend-Server-${count.index + 1}"
  }
}

resource "aws_instance" "backend_servers" {
  count         = 2
  ami           = "ami-01b6d88af12965bb6" 
  instance_type = "t2.micro"

  subnet_id = module.vpc.private_subnets[count.index]

  # Attach the frontend security group
  # vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  tags = {
    Name = "project2-Backend-Server-${count.index + 1}"
  }
}