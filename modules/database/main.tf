# Username and password for RDS
resource "aws_secretsmanager_secret" "rds_mysql" {
  name        = "${var.app_name}-rds-mysql-credentials"
  description = "MySQL RDS credentials for ECS"
}

resource "random_string" "db_username" {
  length  = 8
  upper   = true
  lower   = true
  special = false
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret_version" "rds_mysql_version" {
  secret_id = aws_secretsmanager_secret.rds_mysql.id
  secret_string = jsonencode({
    username = random_string.db_username.result
    password = random_password.db_password.result
  })
}

# RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.app_name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.app_name}-subnet-group"
  }
}

resource "aws_db_instance" "mysql_instance" {
  identifier             = var.app_name
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = jsondecode(aws_secretsmanager_secret_version.rds_mysql_version.secret_string)["username"]
  password               = jsondecode(aws_secretsmanager_secret_version.rds_mysql_version.secret_string)["password"]
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot    = var.skip_final_snapshot

  # multi_az                   = false
  # backup_retention_period    = 7
  # parameter_group_name       = "default.mysql8.0"
  # maintenance_window         = "Mon:00:00-Mon:03:00"
  # publicly_accessible        = false
}
