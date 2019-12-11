output "deployment_group" {
  value = aws_codedeploy_deployment_group.explorer[0].deployment_group_name
}
