variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "aws_key_path" {}
variable "aws_key_name" {}
variable "aws_key_path-2" {}
variable "aws_key_name-2" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-west-2"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.1.0/24"
}

#variable "amis" {
#  type = "map"
#  default = {
#    us-west-2 = "ami-5b6dde3b"
#  }
#}

variable "private-ip" {
    default = "10.0.1.10"
}


variable "rails_image" {
  description = "The name of the Docker image to deploy for the Rails frontend (e.g. gruntwork/rails-frontend)"
  default = "kuldeeps/user_event_scheduler"
}

variable "db_image"{
  description = "The name of db"
  default = "postgres"
}

variable "db_version"
{
  description = "version of db"
  default = "9.4"
}

variable "rails_version" {
  description = "The version (i.e. tag) of the Docker container to deploy for the Rails frontend (e.g. latest, 12345)"
  default = "v5"
}

variable "rails_port" {
  description = "The port the Rails frontend Docker container listens on for HTTP requests (e.g. 3000)"
  default = 3000
}

variable "db_port"
{
  description = "port of db"
  default = 5432
}


variable "ecs_cluster_name" {
  description = "What to name the ECS Cluster"
  default = "example-cluster"
}