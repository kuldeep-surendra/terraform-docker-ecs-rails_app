resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "example-ecs-vpc"
    }
}

resource "aws_internet_gateway" "default"{
    vpc_id = "${aws_vpc.default.id}"
}

resource "aws_subnet" "us-west-2a-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "us-west-2a"

    tags {
        Name = "subnet-ecs-1"
    }
}

resource "aws_subnet" "us-west-2a-private" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "us-west-2a"

    tags {
        Name = "subnet-ecs-2"
    }
}

resource "aws_route_table" "us-west-2a-public"{
    vpc_id = "${aws_vpc.default.id}"
    
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags{
        Name = "route-table-ecs"
    }
}

resource "aws_route_table_association" "us-west-2a-public" {
    subnet_id = "${aws_subnet.us-west-2a-public.id}"
    route_table_id = "${aws_route_table.us-west-2a-public.id}"
}

resource "aws_route_table_association" "us-west-2a-private" {
    subnet_id = "${aws_subnet.us-west-2a-private.id}"
    route_table_id = "${aws_route_table.us-west-2a-public.id}"
}

resource "aws_ecs_task_definition" "rails" {
  family = "rails"
  container_definitions = <<EOF
[
  {
    "name": "rails",
    "image": "${var.rails_image}:${var.rails_version}",
    "cpu": 10,
    "memory": 300,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.rails_port},
        "hostPort": ${var.rails_port},
        "protocol": "tcp"
      }
    ],
    "environment": [
      {"name": "RAILS_ENV", "value": "production"}
    ],
    "links": ["db"]
  },
  {
    "name": "db",
    "image": "${var.db_image}:${var.db_version}",
    "cpu": 10,
    "memory": 300,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.db_port},
        "hostPort": ${var.db_port},
        "protocol": "tcp"
      }
    ],
    "hostname": "postgres"
  }
]
EOF
}

resource "aws_ecs_service" "rails" {
  name = "rails"
  cluster = "${aws_ecs_cluster.example_cluster.id}"
  task_definition = "${aws_ecs_task_definition.rails.arn}"
  desired_count = 2
  deployment_minimum_healthy_percent = 50
  depends_on = ["aws_iam_role_policy.ecs_service_policy"]
  #iam_role = "${aws_iam_role.ecs_service_role.arn}"
 

#  load_balancer {
#    elb_name = "${aws_elb.rails.id}"
#    container_name = "rails"
#    container_port = "${var.rails_port}"
#  }
}

# The load balancer that distributes load between the EC2 Instances
#resource "aws_elb" "rails" {
#  name = "rails"
#  subnets = ["${aws_subnet.us-west-2a-public.id}","${aws_subnet.us-west-2a-public.id}"]
#  security_groups = ["${aws_security_group.rails_elb.id}"]
#  cross_zone_load_balancing = true
  #instances = ["${aws_launch_configuration.ecs_instance.id}"]

#  health_check {
#    healthy_threshold = 2
#    unhealthy_threshold = 2
#    timeout = 5
#    interval = 30

    # The rails-frontend has a health check endpoint at the /health URL
#    target = "HTTP:${var.rails_port}/health"
#  }

#  listener {
#    instance_port = "${var.rails_port}"
#    instance_protocol = "http"
#    lb_port = 80
#    lb_protocol = "http"
#  }
#}

# The securty group that controls what traffic can go in and out of the ELB
#resource "aws_security_group" "rails_elb" {
#  name = "rails-elb"
#  description = "The security group for the rails ELB"
#  vpc_id = "${aws_vpc.default.id}"

  # Outbound Everything
#  egress {
#    from_port = 0
#    to_port = 0
#    protocol = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  # Inbound HTTP from anywhere
#  ingress {
#    from_port = 80
#    to_port = 80
#    protocol = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}