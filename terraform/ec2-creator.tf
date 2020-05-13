# EC2 AWS Instances creation 
# ----------------------------EC2s----------------------------
# Resource: ansible-bastion
resource "aws_instance" "ec2-bastion" {
  ami           = "${var.ami}"
  subnet_id     = "${var.default-subnet2-list-abc[0]}"
  instance_type = "${var.instance-type}"
  # vpc_security_group_ids      = ["${var.security-groups[0]}"]
  vpc_security_group_ids      = "${var.security-groups}"
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
  ami                         = "${var.ami}"
  subnet_id                   = "${var.default-subnet2-list-abc[2]}"
  instance_type               = "${var.instance-type}"
  vpc_security_group_ids      = "${var.security-groups}"
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
  ami                         = "${var.ami}"
  subnet_id                   = "${var.default-subnet2-list-abc[2]}"
  instance_type               = "${var.instance-type}"
  vpc_security_group_ids      = "${var.security-groups}"
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
  ami                         = "${var.ami}"
  subnet_id                   = "${var.default-subnet2-list-abc[0]}" #Subnet for us-east-2c
  instance_type               = "${var.instance-type}"
  vpc_security_group_ids      = "${var.security-groups}"
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
# ----------------------------LoadBalancer group----------------------------
resource "aws_lb" "ec2-applb" {
  name               = "tf-ec2-applb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.server_sg.id}"]
  subnets            = ["${var.default-subnet2-list-abc[0]}"]

  enable_deletion_protection = true

  tags = {
    Name        = "tf-ec2-lb"
    project     = "${var.proj-tag}"
    responsible = "${var.resp-tag}"
  }
}

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
# ----------------------------Autoscaling group----------------------------
resource "aws_launch_template" "ec2-lt-autoscaling-group" {
  name_prefix   = "tfLaunchTemplate"
  image_id      = "${var.ami}"
  instance_type = "${var.instance-type}"
  # security_groups = ["${aws_security_group.server_sg}"]
}
# ----------------------------UI Scaling stage----------------------------
resource "aws_launch_configuration" "ui_aws_launch" {
  name            = "tf-LC-ui"
  image_id        = "${var.ami}"
  instance_type   = "${var.instance-type}"
  security_groups = ["${var.instance-type}"]
  key_name        = "${var.key-name}"

}

resource "aws_autoscaling_group" "ec2-ui-autoscaling" {
  name               = "tf-as-group-ui"
  availability_zones = "${var.availability-zones}"
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  # health_check_grace_period = 300
  # health_check_type         = "ELB"
  # launch_configuration      = "${aws_launch_configuration.ui_aws_launch.name}"
  # force_delete              = true
  # vpc_zone_identifier       = ["${var.vpc.id}"]

  launch_template {
    id      = "${aws_launch_template.ec2-lt-autoscaling-group.id}"
    version = "$Latest"
  }

  tag {
    key                 = "responsible"
    value               = "${var.resp-tag}"
    propagate_at_launch = true
  }
  tag {
    key                 = "project"
    value               = "${var.proj-tag}"
    propagate_at_launch = true
  }

}
# ----------------------------API Scaling stage----------------------------
resource "aws_launch_configuration" "api_aws_launch-ui" {
  name            = "tf-LC-api"
  image_id        = "${var.ami}"
  instance_type   = "${var.instance-type}"
  security_groups = ["${var.instance-type}"]
  key_name        = "${var.key-name}"

}

resource "aws_autoscaling_group" "ec2-autoscaling-api" {
  name               = "tf-as-group-api"
  availability_zones = "${var.availability-zones}"
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  # health_check_grace_period = 300
  # health_check_type         = "ELB"
  # launch_configuration      = "${aws_launch_configuration.ui_aws_launch.name}"
  # force_delete              = true
  # vpc_zone_identifier       = ["${var.vpc.id}"]

  launch_template {
    id      = "${aws_launch_template.ec2-lt-autoscaling-group.id}"
    version = "$Latest"
  }

  tag {
    key                 = "responsible"
    value               = "${var.resp-tag}"
    propagate_at_launch = true
  }
  tag {
    key                 = "project"
    value               = "${var.proj-tag}"
    propagate_at_launch = true
  }

}
# ----------------------------RDS stage----------------------------
resource "aws_db_instance" "rds-mariadb" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mariadb"
  engine_version    = "10.4.8"
  instance_class    = "db.t2.micro"
  name              = "movie_db"
  username          = "root"
  password          = "applicationuser"
}

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

