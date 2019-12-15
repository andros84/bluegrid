provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

######################################################
# Get latest Amazon Linux 2 ami id for selected region #
######################################################

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
 }
}

resource "aws_key_pair" "bluegrid-key" {
  key_name   = "${var.name}-blue-grid.pub"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHgcoO3mAXOVSHZIxJsPbcSqoK3zADop56ug/hy2urg/V/5nn/TfOK5ZHbIkozlt2sdcOiVUq3vUcW/Ki9KbwsuMKuzw2JubN5IUfpv+XfOp2uxNNQZ/V+Wty1K18GRZGWmUnJNvm5F2yc5RGv6exekJycnYM9deuPPHhwJHzkZ7c2NEu1aRPt20MIZpqEisnrFujc+qwoUBwVMeZWdJjEBdXsbqrjOyVqgqEmt2A+CAwUzQp/8tQ6JN3noGcB80AXnRpZoYRbNU8bcK9BsAGvlr0V3K3tClobutViOLz8FbwMyM/vGqFRvPj4HCjZcx6JVfXYTWnUNLzpU2a2d1dJ Andrija privatni kljuc"
  
}

#######
# VPC #
#######
resource "aws_vpc" "vpc" {
  cidr_block           = "200.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support  = true
  
  tags = {
    Name = "${var.name}-${var.dev_environment}-vpc"
    "user:Client"      = "${var.name}"
    "user:Environment" = "${var.dev_environment}"
  }
}

#########################
# Create public subnets #
#########################
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "200.1.1.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "${var.name}-public-subnet-1"
    "user:Client"      = "${var.name}"
    "user:Environment" = "${var.dev_environment}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "200.1.2.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  
  tags = {
    Name = "${var.name}-public-subnet-2"
    "user:Client"      = "${var.name}"
    "user:Environment" = "${var.dev_environment}"
  }
}

###########################
# Create internet gateway #
###########################
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id    = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.name}-igw"
    "user:Client"      = "${var.name}"
    "user:Environment" = "${var.dev_environment}"
  }
}

################################
#   Create routing tables      #
################################
resource "aws_route_table" "route_table_igw" {
  vpc_id    = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags = {
    Name = "${var.name}-rt"
    "user:Client"      = "${var.name}"
    "user:Environment" = "${var.dev_environment}"
  }
}

########################################
# Associate routing tables with subnet #
########################################

resource "aws_route_table_association" "route_table_igw_pub1" {
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.route_table_igw.id}"
}

resource "aws_route_table_association" "route_table_igw_pub2" {
  subnet_id = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.route_table_igw.id}"
}


########################################
# Security Group for EC2               #
########################################

resource "aws_security_group" "ec2-ssh" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "${var.name}-ssh-sg"
  description = "SSH ports for EC2 servers"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["217.24.0.0/16","95.180.103.76/32","${var.your_public_ip}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["200.1.0.0/16"]
  }

  tags = {
    Name = "${var.name}-ssh-sg"
    "user:Client"      = "${var.name}"
    "user:Environment" = "${var.dev_environment}"
  }
}

resource "aws_security_group" "ec2-web" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "${var.name}-web-sg"
  description = "Web ports for EC2 Web server"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "${var.name}-web-sg"
      "user:Client"      = "${var.name}"
      "user:Environment" = "${var.dev_environment}"
    }
  }

########################################
# Define RDS Security Group #
########################################


resource "aws_security_group" "mysql-sg" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "${var.name}-db-sg"
  description = "DB ports for EC2 single server"


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["200.1.0.0/16","95.180.103.76/32","${var.your_public_ip}"]
  }

  tags = {
      Name = "${var.name}-db-sg"
      "user:Client"      = "${var.name}"
      "user:Environment" = "${var.dev_environment}"
    }
  }

###################
#  Create EC2     #
###################

# WebServer EC2

resource "aws_instance" "webserver" {
  count = "${var.webserver_count}"
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type   = "${var.webserver_instance_size}"
  key_name = "${aws_key_pair.bluegrid-key.key_name}"
  security_groups = [ "${aws_security_group.ec2-ssh.id}", "${aws_security_group.ec2-web.id}"  ]  
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  associate_public_ip_address = true 
  
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = "true"
  }

  volume_tags = {
    Name = "${var.name}-${var.dev_environment}-webserver-volume"
    "user:Client"      = "${var.name}"
    "user:Environment" = "${var.dev_environment}"
  }

  provisioner "remote-exec" {
    inline = ["sleep 80"]
    #inline = ["sudo dnf -y install python"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = "${self.public_ip}"
      private_key = "${file("./key/andrija.pem")}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook --ssh-common-args='-o StrictHostKeyChecking=no' -u ec2-user -i '${self.public_ip},' --private-key ./key/andrija.pem ./install-wp.yml" 
  }

  tags = {
      Name = "${var.name}-${var.dev_environment}-webserver-${count.index + 1}"
      "user:Client"      = "${var.name}"
      "user:Environment" = "${var.dev_environment}"
    }
  }

####################
##  Create EIP     #
####################
#
## Web Server
#
#resource "aws_eip" "eip" {
#  count            = "${var.webserver_count}"
#  instance         = "${element(aws_instance.webserver.*.id, count.index)}"
#  #instance         = "${aws_instance.webserver.id}"
#  vpc              = true
#  depends_on       = [ "aws_internet_gateway.internet_gateway" ]
#
#  tags = {
#      Name = "${var.name}-webserver-eip"
#      "user:Client"      = "${var.name}"
#      "user:Environment" = "${var.dev_environment}"
#    }
#  }
#
#######################################
# Define RDS Subnet Group   #
########################################

resource "aws_db_subnet_group" "mysql" {
  name       = "${var.name}-subnet-db-public"
  description = "RDS Subnet"
  subnet_ids = ["${aws_subnet.public_subnet_1.id}","${aws_subnet.public_subnet_2.id}"]
}

##########################################
# Define RDS for WordPress #
##########################################

resource "aws_db_instance" "mysql_wp" {
  identifier                 = "${var.name}-${var.dev_environment}-wp-db"
  allocated_storage          = "10"
  engine                     = "mysql"
  engine_version             = "5.7.22"
  snapshot_identifier        = ""
  instance_class             = "${var.wp_db_rds_size}"
  storage_type               = "gp2"
  iops                       = "0"
  multi_az                   = "false"
  name                       = "${var.dbname}"
  username                   = "${var.dbuser}"
  password                   = "${var.dbpassword}"
  auto_minor_version_upgrade = "true"
  final_snapshot_identifier  = "${var.name}-${var.dev_environment}-core-final-snapshot"
  skip_final_snapshot        = "true"
  copy_tags_to_snapshot      = "true"
  #publicly_accessible        = "true"
  port                       = "3306"
  vpc_security_group_ids     = ["${aws_security_group.mysql-sg.id}"]
  db_subnet_group_name       = "${aws_db_subnet_group.mysql.name}"
    
  tags = {
      Name = "${var.name}-${var.dev_environment}-wp-db"
      "user:Client"      = "${var.name}"
      "user:Environment" = "${var.dev_environment}"
    }
  }

########################################
## Define Service Target Groups         #
########################################
resource "aws_lb_target_group" "tg-web-wp" {
  name     = "${var.name}-web-wp-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    protocol            = "HTTP"
    }
  
  tags = {
      Name = "${var.name}-web-wp-target"
      "user:Client"      = "${var.name}"
      "user:Environment" = "${var.dev_environment}"
   }
  }

#####################################################
# Attach Ec2 instance to target group  #
#####################################################

resource "aws_lb_target_group_attachment" "web" {
  count            = "${var.webserver_count}"
  target_group_arn = "${aws_lb_target_group.tg-web-wp.arn}"
  target_id        = "${element(aws_instance.webserver.*.id, count.index)}"
  port             = 80
}

###########################################################
# Define Network Load Balancer                            #
###########################################################

resource "aws_lb" "elb_wp" {
  name = "${var.name}-http-elb"

  load_balancer_type               = "application"
  internal                         = false
  security_groups                  = ["${aws_security_group.ec2-web.id}"]
  subnets                          = ["${aws_subnet.public_subnet_1.id}","${aws_subnet.public_subnet_2.id}"]
  enable_deletion_protection = false

  tags = {
      Name = "${var.name}-http-elb"
      "user:Client"      = "${var.name}"
      "user:Environment" = "${var.dev_environment}"
   }
}

###########################################################
# Define Network Load Balancer Listeners                  #
###########################################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.elb_wp.arn}"
  protocol          = "HTTP"
  port              = "80"


  default_action {
    target_group_arn = "${aws_lb_target_group.tg-web-wp.arn}"
    type             = "forward"
  }
}

output "wp_db_end_point" {
	value = "${aws_db_instance.mysql_wp.endpoint}"
}

output "webserver-ip" {
	value = "${aws_instance.webserver[0].public_ip}"
}

output "webserver-ip2" {
	value = "${aws_instance.webserver[1].public_ip}"
}

output "load_balancer_dns_name" {
	value = "${aws_lb.elb_wp.dns_name}"
}