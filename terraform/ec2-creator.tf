# EC2 AWS Instances creation 

resource "aws_instance" "ec2" {
  ami                    = "ami-0e84e211558a022c0"
  subnet_id              = "subnet-f4841b8f"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-053c77de0b13a7275"]
  key_name               = "perfZapataKey"
  ebs_optimized          = "false"
  source_dest_check      = "false"
  #   user_data     = "${data.template_file.user-data.rendered}"
  associate_public_ip_address = "false"

    tags = {
      Name        = "ec2terra"
      project     = "azapatao-rampup"
      responsible = "azapatao"
    }
}


# resource "aws_eip" "ip" {
#   vpc      = true
#   instance = aws_instance.example.id
# }

#   lifecycle {
#     ignore_changes         = ["ami", "user_data", "subnet_id", "key_name", "ebs_optimized", "private_ip"]
#   }
# }

# data "template_file" "user_data" {
#   template = "${file("${path.module}/user_data.tpl")}"
# }
