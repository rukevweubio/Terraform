output "nginx_instance_public_ip" {
  value = aws_instance.nginx.public_ip
}

output "mysql_instance_public_ip" {
  value = aws_instance.mysql.public_ip
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.peer.id
}
