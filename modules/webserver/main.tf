resource "aws_default_security_group" "myapp-sg" {
  vpc_id = var.vpc_id
  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my-ip]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [var.my-ip]
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ var.my-ip ]
  }
  tags = {
    Name = "${var.env_prefix}-sg"
  }

}

data "aws_ami" "linux-image" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_key_pair" "ssh-server" {
  key_name = "Key-Name"
  public_key = "${file(var.public_key_location)}"
}

resource "aws_instance" "my-server" {
  
  ami = data.aws_ami.linux-image.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [ aws_default_security_group.myapp-sg.id  ]
  availability_zone = var.avail_zone
  associate_public_ip_address = true 
  
  key_name = aws_key_pair.ssh-server.key_name

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key)
  }

  
  provisioner "file" {
    source = "script.sh"
    destination = "/home/ec2-user/exec.sh"
  }
  
   user_data = file("script.sh")
   /*
   provisioner "remote-exec" {
     script = file("script.sh") 
     when = create
   }
   provisioner "local-exec" {
     command = "echo ${self.public_ip} > output.txt"
   }
  */
  tags = {
    Name = "${var.env_prefix}-server"
  } 
}