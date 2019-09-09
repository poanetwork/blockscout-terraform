module "regular" {
  source = "./modules/blockscout_instance"

  prefix              = var.prefix
  chains              = var.chains
  instance_type       = var.instance_type
  key_name            = var.key_name
  iam_profile         = aws_iam_instance_profile.explorer.id
  root_block_size     = var.root_block_size
  use_placement_group = var.use_placement_group
  target_group_arn    = ########TODO
  
  type = "regular"

  depends_on = [
    aws_db_instance.default,
    aws_ssm_parameter.db_host,
    aws_ssm_parameter.db_name,
    aws_ssm_parameter.db_port,
    aws_ssm_parameter.db_username,
    aws_ssm_parameter.db_password,
    aws_placement_group.explorer 
  ]
}

module "web" {
  source = "./modules/blockscout_instance"

  type = "web"
#TODO
}

module "api" {
  source = "./modules/blockscout_instance"

  type = "api"
#TODO
}
