resource "aws_key_pair" "bastion-keys" {
  key_name   = "${var.ec2_instance_name}_key_pair"
  public_key = file(var.ssh_pubkey_file)
}

resource "aws_instance" "server" {
  ami                     = var.ami
  instance_type           = var.instance_type
  subnet_id         = aws_subnet.private-subnet-1.id
  security_groups = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  user_data = <<-EOL
  #!/bin/bash -xe
  sudo yum update -y &&
  sudo yum -y install docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo chmod 666 /var/run/docker.sock

  docker pull nginx
  docker tag nginx my-nginx
  docker run --rm --name nginx-server -d -p 80:80 -t my-nginx
  echo "Hello World" > /var/www/html/index.html
  EOL
  depends_on = [aws_nat_gateway.ngw]
}


resource "aws_lb_target_group_attachment" "zaka4alka-server" {
  target_group_arn = "${aws_alb_target_group.default-target-group.arn}"
  target_id        = "${aws_instance.server.id}"
  port             = 80
}

