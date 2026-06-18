output "ec2_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.docker_host.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of EC2 instance"
  value       = aws_instance.docker_host.public_dns
}
