module "gitlab_runner" {
  source      = "../modules/gitlab-runner"
  name_prefix = local.name_prefix
  environment = var.environment
  ssm_prefix  = local.ssm_prefix

  gitlab_runner_token = var.gitlab_runner_token

  vpc_id             = module.vpc.vpc_id
  vpc_subnet_id      = element(module.vpc.private_subnets, 0)
  security_group_ids = [module.private_services_sg.security_group_id]
}
