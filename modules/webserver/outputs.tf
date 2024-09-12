output "latest-amazon-linux-image" {
  value = data.aws_ami.latest-amazon-linux-image
}

output "server-public-ip" {
  value = aws_instance.myapp-server.public_ip
}