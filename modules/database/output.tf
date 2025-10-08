output "rds_secret_username_valuefrom" {
  description = "Secrets Manager valueFrom path cho DB_USERNAME"
  value       = "${aws_secretsmanager_secret.rds_mysql.arn}:username::"
}

output "rds_secret_password_valuefrom" {
  description = "Secrets Manager valueFrom path cho DB_PASSWORD"
  value       = "${aws_secretsmanager_secret.rds_mysql.arn}:password::"
}

output "rds_host" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.mysql-instance.endpoint
}
