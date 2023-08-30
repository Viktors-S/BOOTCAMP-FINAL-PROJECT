
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
resource "aws_security_group" "ViktorsSeilisTerraformSecurityGroup" {
    name_prefix = "ViktorsSeilisTerraformSecurityGroup"

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

//setup EC2 instance
resource "aws_instance" "ViktorsSeilisTerraform" {
    ami = "ami-04e601abe3e1a910f"
    instance_type = "t2.micro"
    key_name = local.key_name
    associate_public_ip_address = true

    vpc_security_group_ids = [aws_security_group.ViktorsSeilisTerraformSecurityGroup.id]

    //add tags (like instance name, etc.)
    tags = {
      Name = "Viktors Seilis terraform instance"
    }

    provisioner "remote-exec" {
      inline = [ "echo 'Wait until SSH is ready'" ]

      connection {
        type = "ssh"
        user = local.ssh_user
        private_key = file(local.private_key_path)
        host = aws_instance.ViktorsSeilisTerraform.public_ip
      }
    }


    provisioner "local-exec" {
        command = "ansible-playbook -i ${aws_instance.ViktorsSeilisTerraform.public_ip} --private-key ${local.private_key_path} nginx.yaml"
    }
}

output "nginx_ip" {
    value = aws_instance.ViktorsSeilisTerraform.public_ip
}
