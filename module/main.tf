resource "aws_instance" "instance" {
  ami           = data.aws_ami.centos.image_id
  instance_type = var.instance_type
  vpc_security_group_ids =  [ data.aws_security_group.selected.id ]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = local.name
  }
}
resource "null_resource" "provisioner" {
  depends_on = [aws_instance.instance, aws_route53_record.dnsrecords]
  triggers = {
    private_ip = aws_instance.instance.private_ip
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "centos"
      password = "DevOps321"
      host     = aws_instance.instance.private_ip
    }
    inline = var.app_type == "db" ? local.db_commands : local.app_commands
  }
}
resource "aws_route53_record" "dnsrecords" {
  zone_id = "Z04557643QUL1Q83BTGGA"
  name    = "${var.component_name}-dev.vemdevops.online"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}

resource "aws_iam_role" "role" {
  name = "${var.component_name}-${var.env}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.component_name}-${var.env}-role"
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.component_name}-${var.env}-role"
  role = aws_iam_role.role.name
}

resource "aws_iam_role_policy" "ssm-ps-policy" {
  name = "${var.component_name}-${var.env}-ssm-ps-policy"
  role = aws_iam_role.role.id

   policy = jsonencode({
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "VisualEditor0",
         "Effect": "Allow",
         "Action": [
           "kms:Decrypt",
           "ssm:GetParameterHistory",
           "ssm:GetParametersByPath",
           "ssm:GetParameters",
           "ssm:GetParameter"
         ],
         "Resource": [
           "arn:aws:kms:us-east-1:689505382884:key/8ad7b83e-d322-4cb4-a3cf-f1210e2a762a",
           "arn:aws:ssm:us-east-1:689505382884:parameter/${var.env}.${var.component_name}.*"
         ]
       }
       ]
   })
}

