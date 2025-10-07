output "endpoint" {
  value = aws_db_instance.mysql_instance.endpoint
}

output "port" {
  value = aws_db_instance.mysql_instance.port
}

output "address" {
  value = aws_db_instance.mysql_instance.address
}

output "arn" {
  value = aws_db_instance.mysql_instance.arn
}
