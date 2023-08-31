
locals {
  ssh_user="ubuntu"
  key_name="ViktorsKEYpersonal"//change
  private_key_path="~/Downloads/ViktorsKEYpersonal.pem"
}

terraform {
    //download the required providers
    required_providers{
        aws={
            source = "hashicorp/aws"
            version = "~> 3.5.0"
        }
    }
}

//setup provider region
provider "aws" {
    region = "eu-central-1"
}



//setup the security group
resource "aws_security_group" "ViktorsSeilisAnsibleSecurityGroup" {
    name_prefix = "ViktorsSeilisAnsible"

    // Inbound SSH rule
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    // Inbound HTTP rule
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    // Inbound HTTPS rule
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    // Outbound HTTP and HTTPS rule
    egress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}



resource "aws_key_pair" "nginxkey" {
    key_name = "nginx_key"
    public_key = file("~/.ssh/id_rsa.pub")
}

//setup EC2 instance
resource "aws_instance" "ViktorsSeilisAnsible" {
    ami = "ami-04e601abe3e1a910f"
    instance_type = "t2.micro"
    key_name = aws_key_pair.nginxkey.key_name
    associate_public_ip_address = true

    vpc_security_group_ids = [aws_security_group.ViktorsSeilisAnsibleSecurityGroup.id]

    //add tags (like instance name, etc.)
    tags = {
      Name = "Viktors Seilis ansible instance"
    }
}

output "nginx_ip" {
    value = aws_instance.ViktorsSeilisAnsible.public_ip
}
