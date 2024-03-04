resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu_22_04_ami.id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public[0].id
  
  tags = {
    Name = "Cloudhight"
  }
}