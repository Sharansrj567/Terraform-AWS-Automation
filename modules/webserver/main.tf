resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name: "${var.env_prefix}-security-group"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# auto generated ssh-key
resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  # public key must already exist locally on your machine
  public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server" {
  # --- required Attributes ---
  # Amazon Machine Image (OS)
  ami = data.aws_ami.latest-amazon-linux-image.id
  # Server size
  instance_type = var.instance_type

  # --- optional Attributes ---
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone = var.avail_zone

  # should be accessible from outside
  associate_public_ip_address = true

  # name of the key-pair file for ssh connection
  # the file should be downloaded und put into .ssh folder
  # "chown 400 filename.pem"
  # ssh -i ~/.ssh/filename.pem ec2-user@servers.public.ip.address
  #  key_name = "server-key-pair"

  # auto generated key-pair
  # ssh with your *private* key
  # ssh -i ~/.ssh/id_ed25519 ec2-user@server.public.ip.address
  #     -i ~/.ssh/id_ed25519 is defautl
  #     -> "ssh ec2-user@server.public.ip.address"
  key_name = aws_key_pair.ssh-key.key_name

  # kind of entrypoint of server
  # executed once on **initial start up** (not every start up)
  # --- passing data to AWS ---
  #  user_data = file("entry-script.sh")

  # connection belongs to provisioner
  # tells how to connect to the server
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_location)
  }

  # copy files or directories from local to newly created resource
  provisioner "file" {
    # path on local machine
    source = "entry-script.sh"
    # path on remote machine
    destination = "/home/ec2-user/entry-script-on-ec2.sh"

    # you can define an additional connection to copy the file to another server
    # connection { ... }
  }

  # remote-exec - invokes script on a remote resource after it is created
  # --- connect via ssh using Terraform ---
  provisioner "remote-exec" {
    # inline - list of commands
    inline = [
      "export ENV=dev",
      "mkdir newdir"
    ]

    # script - path to scriptFile.sh on server!
    # the script should already exist!!!
    # copy the file first with file-provisioner
    # ---
    # this function works only with files that are distributed as part of the configuration source code, so if this file will be created by a resource in
    # this configuration you must instead obtain this result from an attribute of that resource.
    #    script = file("entry-script-on-ec2.sh")
  }

  # invokes a local (on this host) executable after a resource is created
  # locally, NOT on the created resource!
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > output.txt"
  }

  tags = {
    Name: "${var.env_prefix}-server"
  }
}