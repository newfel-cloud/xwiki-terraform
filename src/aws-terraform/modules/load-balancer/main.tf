module "load_balancer" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.1.0"

  target_groups = [
    {
      target_type      = "instance"
      name             = "${var.region}-tg" //"name" cannot be longer than 32 characters
      backend_protocol = "HTTP"
      backend_port     = 8080
      targets = {
        instance1 = {
          target_id = "${var.ec2_1.id}"
          port      = 8080
        }
        instance2 = {
          target_id = "${var.ec2_2.id}"
          port      = 8080
        }
      }
      health_check = {
        enabled             = true
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 5
        timeout             = 5
        interval            = 30
        //path                = "/xwiki/bin/main/View"
      }
    },
    {
      target_type      = "instance"
      name             = "${var.region}-tg-auto" //"name" cannot be longer than 32 characters
      backend_protocol = "HTTP"
      backend_port     = 8080
      health_check = {
        enabled             = true
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 5
        timeout             = 5
        interval            = 30
        //path                = "/xwiki/bin/main/View"
      }
    }
  ]
  load_balancer_type = "application"
  name               = "a-${var.region}-elb-http-8080"
  vpc_id             = var.vpc.id
  subnets = [
    var.subnets[0].id,
    var.subnets[1].id
  ]

  security_groups = [
    var.sg_map["common"].security_group_id,
    //var.sg_map["remote"].security_group_id,
  ]
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = module.load_balancer.lb_arn
  port              = 8080
  protocol          = "HTTP"
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = module.load_balancer.target_group_arns[0]
        weight = 1
      }
      target_group {
        arn    = module.load_balancer.target_group_arns[1]
        weight = 3
      }
    }
  }
}

module "auto_scaling_group" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  # Autoscaling group
  name                   = "a-${var.region}-auto-group"
  create_launch_template = false
  //launch_template_name   = var.template.name
  launch_template            = var.template.name
  use_mixed_instances_policy = true
  update_default_version     = true
  vpc_zone_identifier = [
    var.subnets[0].id,
    var.subnets[1].id
  ]

  target_group_arns = [
    module.load_balancer.target_group_arns[1],
  ]

  desired_capacity = 1
  min_size         = 1
  max_size         = 10
  scaling_policies = {
    my-policy = {
      policy_type = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    }
  }
}
