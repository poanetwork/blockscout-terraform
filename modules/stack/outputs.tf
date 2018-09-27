output "codedeploy_app" {
  description = "The name of the CodeDeploy application"
  value       = "${aws_codedeploy_app.explorer.name}"
}

output "codedeploy_deployment_group_names" {
  description = "The names of all the CodeDeploy deployment groups"
  value       = "${aws_codedeploy_deployment_group.explorer.*.deployment_group_name}"
}

output "codedeploy_bucket" {
  description = "The name of the CodeDeploy S3 bucket for applciation revisions"
  value       = "${aws_s3_bucket.explorer_releases.id}"
}

output "codedeploy_bucket_path" {
  description = "The path for releases in the CodeDeploy S3 bucket"
  value       = "/"
}

output "explorer_urls" {
  description = "A map of each chain to the DNS name of its corresponding Explorer instance"
  value       = "${zipmap(keys(var.chains), aws_lb.explorer.*.dns_name)}"
}

output "db_instance_address" {
  description = "The IP address of the RDS instance"
  value       = "${aws_db_instance.default.address}"
}
