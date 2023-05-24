data "aws_ami" "centos" {
  owners           = ["973714476881"]
  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"

}
variable "ins_type" {
  default = "t3.small"
}
variable "components" {
  default = ["frontend", "mongodb", "catalogue"]
}
data "aws_security_group" "selected" {
  name = "allow_all"
}

 resource "aws_instance" "instance" {
  ami           = data.aws_ami.centos.image_id
  instance_type = var.ins_type
   count = length(var.components)
vpc_security_group_ids = [ data.aws_security_group.selected.id ]

tags = {
  Name = var.components[count.index]
}
}
/*
resource "aws_route53_record" "frontend" {
  zone_id = "Z04557643QUL1Q83BTGGA"
  name    = "frontend-dev.vemdevops.online"
  type    = "A"
  ttl     = 30
  records = [aws_instance.frontend.private_ip]
}
*/
