resource "aws_security_group" "rds_sg" {
  name        = "project2-rds-sg"
  description = "Allow MySQL access from VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "project2-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "project2-rds-subnet-group"
  }
}


resource "aws_db_instance" "mysql" {
  identifier = "project2-mysql"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro" # or db.t3.small

  allocated_storage = 20

  db_name  = "projectdb"
  username = "admin"
  password = "postgres123"

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az            = false
  publicly_accessible = false

  skip_final_snapshot = true

  tags = {
    Name = "project2-mysql"
  }
}
