resource "aws_codedeploy_deployment_group" "explorer" { 
  count                 = var.instance_number > 0 ? 1 : 0 
  app_name              = var.codedeploy_app 
  deployment_group_name = "${var.prefix}-${var.chain}-${var.type}-explorer-dg" 
  service_role_arn      = var.iam_deployer 
  autoscaling_groups    = [aws_autoscaling_group.explorer.name] 

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.common.name
    }
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 30
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 15
    }
  }
}

