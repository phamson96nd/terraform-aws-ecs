output "endpoint" {
  value = aws_db_instance.mysql-instance.endpoint
}

output "port" {
  value = aws_db_instance.mysql-instance.port
}

output "address" {
  value = aws_db_instance.mysql-instance.address
}

output "arn" {
  value = aws_db_instance.mysql-instance.arn
}
