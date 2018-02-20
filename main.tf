##################################################################################
# VARIABLES
##################################################################################
variable "private_key_path" {}
variable "key_name" {
  default = "centos"
}


##################################################################################
# PROVIDERS
##################################################################################
provider "aws" {
    profile = "default"
    region  = "eu-west-1"
}


##################################################################################
# RESOURCES
##################################################################################
resource "aws_default_vpc" "default" {
  tags {
      Name = "Default VPC"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_default_vpc.default.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["82.46.121.164/32"]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "centos" {
  ami           = "ami-6e28b517"
  instance_type = "t2.micro"
  key_name        = "${var.key_name}"

  connection {
    user        = "centos"
    private_key = "${file(var.private_key_path)}"
  }
  
  provisioner "file" {
    source      = "install_terraform.sh"
    destination = "/tmp/install_terraform.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install yum-plugin-fastestmirror",
      "chmod +x /tmp/install_terraform.sh",
      "sudo /tmp/install_terraform.sh",
    ]
  }
}  

output "public_dns" {
  value = ["${aws_instance.centos.public_dns}"]
}