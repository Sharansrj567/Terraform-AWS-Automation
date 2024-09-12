output "aws_ami_id" {
  value = module.myapp-webserver.latest-amazon-linux-image.id
}

output "ec2_public_ip" {
  value = module.myapp-webserver.server-public-ip
}