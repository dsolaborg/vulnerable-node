######## Loadbalancer for vulnerable nodeJS
provider "aws" {
  version = "~> 1.0"
  region  = "${var.aws_region}"
}

provider "template" {
  version = "~> 1.0"
}

# Generate random UUID
resource "random_uuid" "stack_id" {}

resource "aws_lb" "front_end" {
  name               = "alb-${var.environment}-${var.owner}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${lookup(var.sg_id, var.environment)}","sg-07d8de1d6c7dc6303"]
  subnets            = ["subnet-004db3a8b97237878","subnet-0d26f005d88b4db98"]

  enable_deletion_protection = false

  tags {
    Name = "cloudwatchloggroup_${random_uuid.stack_id.result}"
    Owner = "${var.owner}"
    Email = "${var.owner_email}"
    Environment = "${var.environment}"
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "tg-${var.environment}${var.owner}"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${lookup(var.vpc_id, var.environment)}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path              = "/login?returnurl=/"
    interval            = 30
    port                = "3000"
  }
  depends_on = ["aws_lb.front_end"]

}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = "${aws_lb.front_end.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-2018-06"
  certificate_arn   = "${var.arn_acme}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.front_end.arn}"
  }
}

resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = "${aws_lb.front_end.arn}"
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.front_end.arn}"
  }
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = "${aws_lb_listener.front_end_http.arn}"

  action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}

# Create a new ALB Target Group attachment
resource "aws_lb_target_group_attachment" "node" {
  target_group_arn = "${aws_lb_target_group.front_end.arn}"
  target_id        = "${var.instance_id}"
  port             = 3000
}

################### route53

resource "aws_route53_record" "www" {
  zone_id = "${var.zone_id}"
  name    = "${var.owner}-${lookup(var.short_env, var.environment)}.${var.dso_domain}"
  type    = "A"

  alias {
    name                   = "${aws_lb.front_end.dns_name}"
    zone_id                = "${aws_lb.front_end.zone_id}"
    evaluate_target_health = true
  }
}
