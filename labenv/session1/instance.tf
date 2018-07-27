resource "aws_key_pair" "tiger_key" {
  key_name = "${var.SSH_KEY_NAME}"
  public_key = "${file("${var.SSH_PUBLIC_KEY_FILE_PATH}")}"  
}


resource "aws_instance" "tiger_machine" {
  ami           = "ami-ee8ea481"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.tiger_sec_group.id}"]  
  key_name = "${aws_key_pair.tiger_key.key_name}"
  tags {
    Name = "tiger.machine"
  }
  user_data = <<-EOF
  #!/bin/bash
  echo "Hello World" > index.html
  nohup busybox httpd -f -p ${var.SERVER_PORT} &
  EOF
}

resource "aws_security_group" "tiger_sec_group" {
  name = "tiger_sec_group"
  ingress {
    from_port = "${var.SERVER_PORT}"
    to_port = "${var.SERVER_PORT}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allowing traffic to our web server"
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["106.51.28.186/32"]
    description = "Allowing ssh from my client"
  }
}

output "tiger_public_ip" {
  value = "${aws_instance.tiger_machine.public_ip}"
}
