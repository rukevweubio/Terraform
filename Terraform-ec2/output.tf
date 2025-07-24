output "public_instance_1_public_ip" {
  description = "Public IP of the first EC2 instance"
  value       = aws_instance.ec2_1.public_ip
}

output "public_instance_2_public_ip" {
  description = "Public IP of the second EC2 instance"
  value       = aws_instance.ec2_2.public_ip
}

output "load_balancer_dns_name" {
  description = "DNS name of the Load Balancer"
  value       = aws_lb.app_lb.dns_name
}
