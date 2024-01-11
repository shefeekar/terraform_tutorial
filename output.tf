output "instance_public_ip" {
  value = aws_instance.web-server-instance.public_ip
}
