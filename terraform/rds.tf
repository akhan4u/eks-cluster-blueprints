resource "aws_security_group" "harbor_database" {
  name   = "harbor_security_group"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Harbor Security Group"
  }
}

resource "aws_db_subnet_group" "harbor_database_subnet_group" {
  name       = "harbor_subnet_group"
  subnet_ids = module.vpc.private_subnets
  tags = {
    Name = "Harbor Subnet Group"
  }
}

resource "random_password" "master_password" {
  length = 16
  # RDS DB password does not support special characters
  special = false
}

resource "aws_secretsmanager_secret" "harbor_pg_master_connection" {
  name = "${var.deploy_stage}_rds_pg_master_connection_harbor"
}

resource "aws_secretsmanager_secret_version" "harbor_pg_master_connection" {
  secret_id = aws_secretsmanager_secret.harbor_pg_master_connection.id
  secret_string = jsonencode({
    address        = aws_db_instance.harbor.address
    db_name        = aws_db_instance.harbor.db_name
    engine         = aws_db_instance.harbor.engine
    engine_version = aws_db_instance.harbor.engine_version_actual
    password       = random_password.master_password.result
    port           = aws_db_instance.harbor.port
    username       = aws_db_instance.harbor.username
    DATABASE_URL   = "postgres://${aws_db_instance.harbor.username}:${random_password.master_password.result}@${aws_db_instance.harbor.address}:${aws_db_instance.harbor.port}/postgres"
  })
}

resource "aws_db_instance" "harbor" {
  allocated_storage      = var.db_instance_storage
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.harbor_database_subnet_group.name
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  identifier             = "harbor-database"
  instance_class         = var.db_instance_type
  password               = random_password.master_password.result
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_type           = "gp2"
  username               = var.db_instance_username
  vpc_security_group_ids = [aws_security_group.harbor_database.id]
}
