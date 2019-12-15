variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "region" {
}

variable "name" {
}

variable "webserver_count" {
}

variable "dev_environment" {
  default = "demo"
}

variable "your_public_ip" {
}

variable "dbname" {
  default = "wp_blue_db"
}

variable "dbuser" {
  default = "blue"
}

variable "dbpassword" {
  default = "BlueGrid#2403"
}

variable "vpc_cidr_block" {
  default = "200.1.0.0/16"
}

variable "webserver_instance_size" {
  default = "t2.micro"
}

variable "wp_db_rds_size" {
  default = "db.t2.micro"
}

data "aws_availability_zones" "available" {}