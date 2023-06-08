resource "aws_instance" "instance" {
  ami           = data.aws_ami.centos.image_id
  instance_type = var.instance_type
  vpc_security_group_ids =  [ data.aws_security_group.selected.id ]

  tags = {
    Name = var.component_name
  }
}
resource "null_resource" "provisioner" {

  depends_on = [aws_instance.instance, aws_route53_record.dnsrecords]
  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = "centos"
      password = "DevOps321"
      host     = aws_instance.instance.private_ip
    }

    inline = [
      "rm -rf roboshop-shell",
      "git clone https://github.com/kvmallika/roboshop-shell.git",
      "cd roboshop-shell" ,
      "sudo bash ${var.component_name}.sh ${var.password}"
    ]

  }
}
resource "aws_route53_record" "dnsrecords" {
  for_each = var.components
  zone_id = "Z04557643QUL1Q83BTGGA"
  name    = "${var.component_name}-dev.vemdevops.online"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}
