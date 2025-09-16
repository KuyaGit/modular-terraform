locals {
  application_name                   = "${var.name_prefix}-gitlab-runner"
  gitlab_runner_token_ssm_param_name = "${var.ssm_prefix}/runners/gitlab/authentication_token"
}
