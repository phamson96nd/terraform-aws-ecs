output "instance_ip_addr_public" {
  value = aws_eip.bastion_eip.public_ip
}

output "instance_ip_addr_private" {
  value = aws_instance.bastion_instance.private_ip
}
