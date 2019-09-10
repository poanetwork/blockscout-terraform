module "regular" {
  source = "./modules/blockscout_instance" 
  
  count               = length(var.chains)

  prefix              = var.prefix
  chain               = var.chains[count.index]
  instance_number     = var.regular_instances[var.chains[count.index]]
  instance_type       = var.instance_type
  key_name            = var.key_name
  iam_profile         = aws_iam_instance_profile.explorer.id
  iam_deployer        = aws_iam_role.deployer.arn
  root_block_size     = var.root_block_size
  use_placement_group = var.use_placement_group[var.chains[count.index]]
  alb_listener        = aws_alb_listener.alb_listener[var.chains[count.index]].arn
  security_app        = aws_security_group.app.id
  codedeploy_app      = aws_codedeploy_app.explorer.name
  aws_vpc             = aws_vpc.vpc.id
  aws_subnet          = aws_subnet.default.id

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
  
  count               = length(var.chains)

  prefix              = var.prefix
  chain               = var.chains[count.index]
  instance_number     = var.regular_instances[var.chains[count.index]]
  instance_type       = var.instance_type
  key_name            = var.key_name
  iam_profile         = aws_iam_instance_profile.explorer.id
  iam_deployer        = aws_iam_role.deployer.arn
  root_block_size     = var.root_block_size
  use_placement_group = var.use_placement_group[var.chains[count.index]]
  alb_listener        = aws_alb_listener.alb_listener[var.chains[count.index]].arn
  security_app        = aws_security_group.app.id
  codedeploy_app      = aws_codedeploy_app.explorer.name
  aws_vpc             = aws_vpc.vpc.id
  aws_subnet          = aws_subnet.default.id

  type = "web"

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

module "api" {
  source = "./modules/blockscout_instance" 
  
  count               = length(var.chains)

  prefix              = var.prefix
  chain               = var.chains[count.index]
  instance_number     = var.regular_instances[var.chains[count.index]]
  instance_type       = var.instance_type
  key_name            = var.key_name
  iam_profile         = aws_iam_instance_profile.explorer.id
  iam_deployer        = aws_iam_role.deployer.arn
  root_block_size     = var.root_block_size
  use_placement_group = var.use_placement_group[var.chains[count.index]]
  alb_listener        = aws_alb_listener.alb_listener[var.chains[count.index]].arn
  security_app        = aws_security_group.app.id
  codedeploy_app      = aws_codedeploy_app.explorer.name
  aws_vpc             = aws_vpc.vpc.id
  aws_subnet          = aws_subnet.default.id

  type = "api"

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
