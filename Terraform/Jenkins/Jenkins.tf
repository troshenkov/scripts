#------------------
# Build Jenkins on AWS
#------------------

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "jenkins" {
  count                  = 1
  ami                    = "ami-0ac05733838eabc06"
  instance_type          = "t3.micro"
  key_name               = "mit"
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  user_data              = file("user_data.sh")

  tags = {
    Name  = "Jenkins"
    Owner = "Dmitry Troshenkov"
  }

}

resource "aws_security_group" "jenkins" {
  name        = "Jenkins Security Group"
  description = "Me Jenkins Security Group"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Jenkins Security Group"
    Owner = "Dmitry Troshenkov"
  }

}
