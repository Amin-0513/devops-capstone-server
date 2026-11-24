output "vpc_id" {
  value = aws_vpc.saa_vpc.id
}

output "subnet_id" {
  value = aws_subnet.saa_public_subnet.id
}

output "security_group_id" {
  value = aws_security_group.saa_sg.id
}

output "server_public_ip" {
  value = aws_instance.server.public_ip
}

output "grafana_url" {
  value = "http://${aws_instance.server.public_ip}:${var.grafana_port}"
}

output "server_private_ip" {
  value = aws_instance.server.private_ip
}
