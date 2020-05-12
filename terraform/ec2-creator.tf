# EC2 AWS Instances creation 
# ----------------------------EC2s----------------------------
# Resource: ansible-bastion
resource "aws_instance" "ec2-bastion" {
  ami                         = "ami-07c1207a9d40bc3bd"
  subnet_id                   = "subnet-f4841b8f" #Subnet for us-east-2a
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["sg-053c77de0b13a7275"] #default-ssh-example-2
  key_name                    = "${var.key-name}"
  ebs_optimized               = "false"
  source_dest_check           = "false"
  user_data                   = "${data.template_file.bastion-user-data.rendered}"
  associate_public_ip_address = "true"
  tags = {
    Name        = "tfBastion"
    project     = "${var.proj-tag}"
    responsible = "${var.resp-tag}"
  }
  volume_tags = {
    project     = "${var.proj-tag}"
    responsible = "${var.resp-tag}"
  }
}
data "template_file" "bastion-user-data" {
  template = "${file("${path.module}/bastion-user-data.tpl")}"
}

resource "aws_instance" "ec2-api" {
  ami                         = "ami-07c1207a9d40bc3bd"
  subnet_id                   = "subnet-d28b2a9f" #Subnet for us-east-2c
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["sg-053c77de0b13a7275"] #default-ssh-example-2
  key_name                    = "${var.key-name}"
  ebs_optimized               = "false"
  source_dest_check           = "false"
  associate_public_ip_address = "true"
  # count                       = 4

  tags = {
    Name        = "tfApi"
    project     = "${var.proj-tag}"
    responsible = "${var.resp-tag}"
  }
  volume_tags = {
    project     = "${var.proj-tag}"
    responsible = "${var.resp-tag}"
  }
}

resource "aws_instance" "ec2-Ui" {
  ami                         = "ami-07c1207a9d40bc3bd"
  subnet_id                   = "subnet-966331ff" #Subnet for us-east-2c
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["sg-053c77de0b13a7275"] #default-ssh-example-2
  key_name                    = "${var.key-name}"
  ebs_optimized               = "false"
  source_dest_check           = "false"
  associate_public_ip_address = "true"
  tags = {
    Name        = "tfUi"
    project     = "${var.proj-tag}"
    responsible = "${var.resp-tag}"
  }
  volume_tags = {
    project     = "${var.proj-tag}"
    responsible = "${var.resp-tag}"
  }
}

resource "aws_instance" "ec2-auto-server" {
  ami                         = "ami-07c1207a9d40bc3bd"
  subnet_id                   = "subnet-966331ff" #Subnet for us-east-2c
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["sg-053c77de0b13a7275"] #default-ssh-example-2
  key_name                    = "${var.key-name}"
  ebs_optimized               = "false"
  source_dest_check           = "false"
  associate_public_ip_address = "true"
  user_data                   = "${data.template_file.jenkins-user-data.rendered}"
  tags = {
    Name        = "tfJenk"
    project     = "${var.proj-tag}"
    responsible = "${var.resp-tag}"
  }
  volume_tags = {
    project     = "${var.proj-tag}"
    responsible = "${var.resp-tag}"
  }
}


data "template_file" "jenkins-user-data" {
  template = "${file("${path.module}/jenkins-user-data.tpl")}"
}
# ----------------------------Autoscaling group----------------------------


resource "aws_lb_target_group" "ec2-lb-targetGroup" {
  name     = "tf-ec2-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc}"

  # vpc_id   = "${aws_vpc.main.id}"
}

# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
# }

# ----------------------------Security group----------------------------
resource "aws_security_group" "server_sg" {
  name        = "az-ramp-up-sg"
  description = "Allow traffic"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "provisioning"
  }

  # ingress {
  #   from_port   = "${var.c10k_server_port}"
  #   to_port     = "${var.c10k_server_port}"
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "servers"
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "eprovisioning"
  }
}
#ALB A

resource "aws_launch_configuration" "ui_aws_launch"{
  name = "tf-LC-ui"
  instance_type = "${var.instance-type}"
  security_groups = ["${var.instance-type}"]
  key_name = "${var.key-name}"

}
resource "aws_launch_template" "ec2-autoscaling-group" {
  name_prefix   = "tfLaunchTemplate"
  image_id      = "${var.ami}"
  instance_type = "t2.micro"
}#falta security group 

# resource "aws_autoscaling_group" "ec2-autoscaling" {
#   name               = "tf-as-group"
#   availability_zones = ["us-east-2a"]
#   desired_capacity   = 1
#   max_size           = 3
#   min_size           = 1

  # tag {
  #   key = "responsible"
  #   value = "${var.resp-tag}"
  #   propagate_at_launch = true
  # }
  #   tag {
  #   key = "project"
  #   value = "${var.proj-tag}"
  #   propagate_at_launch = true
  # }

# }

# resource "aws_eip" "ip" {
#   vpc      = true
#   instance = aws_instance.example.id
# }
#   lifecycle {
#     ignore_changes         = ["ami", "user_data", "subnet_id", "key_name", "ebs_optimized", "private_ip"]
#   }
# }
# test dynamic inventory -FAILED
# module "ansible_provisioner" {
#   source = "github.com/cloudposse/tf_ansible"

#   arguments = ["--user=ubuntu"]
#   envs      = ["host=${join("\n", aws_instance.ec2-api.*.public_ip)}"]
#   playbook  = "./ec2.yml"
#   dry_run   = false
# }

