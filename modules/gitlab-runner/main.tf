# Create IAM role for GitLab Runner
resource "aws_iam_role" "gitlab_runner" {
  name = "${local.application_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Application = local.application_name
  }
}

# Attach required policies to the IAM role
resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.gitlab_runner.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.gitlab_runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile
resource "aws_iam_instance_profile" "gitlab_runner" {
  name = "${local.application_name}-profile"
  role = aws_iam_role.gitlab_runner.name
}

resource "aws_ssm_parameter" "gitlab_runner_registration_token" {
  name  = local.gitlab_runner_token_ssm_param_name
  type  = "SecureString"
  value = var.gitlab_runner_token

  tags = {
    Environment = var.environment
    Application = local.application_name
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = var.vpc_id
}

module "runner" {
  # source                                = "cattle-ops/gitlab-runner/aws"
  # version                               = "7.7.0"
  # environment                           = local.application_name
  # vpc_id                                = var.vpc_id
  # subnet_id                             = var.vpc_subnet_id
  # runner_worker_docker_add_dind_volumes = true

  # runner_instance = {
  #   collect_autoscaling_metrics = ["GroupDesiredCapacity", "GroupInServiceCapacity"]
  #   name                        = local.application_name
  #   ssm_access                  = true
  #   instance_type               = "t3.micro"
  #   market_options              = "spot"
  #   instance_profile            = aws_iam_instance_profile.gitlab_runner.name
  #   metadata_options = {
  #     http_endpoint               = "enabled"
  #     http_tokens                 = "required"
  #     http_put_response_hop_limit = 1
  #   }
  # }

  # runner_gitlab = {
  #   url                                           = var.gitlab_url
  #   preregistered_runner_token_ssm_parameter_name = local.gitlab_runner_token_ssm_param_name
  # }

  # runner_networking = {
  #   allow_incoming_ping_security_group_ids = [data.aws_security_group.default.id]
  # }

  # runner_cloudwatch = {
  #   enabled        = true
  #   retention_days = 3
  # }

  # tags = {
  #   "tf-aws-gitlab-runner:instancelifecycle" = "spot:yes"
  # }

  # https://registry.terraform.io/modules/cattle-ops/gitlab-runner/aws/
  source      = "cattle-ops/gitlab-runner/aws"
  version     = "9.2.1"
  environment = local.application_name

  vpc_id    = var.vpc_id
  subnet_id = var.vpc_subnet_id

  runner_instance = {
    name                        = local.application_name
    collect_autoscaling_metrics = ["GroupDesiredCapacity", "GroupInServiceCapacity"]
    ssm_access                  = true
    instance_type               = "t3.micro"
    market_options              = "spot"
  }

  runner_gitlab = {
    url = "https://gitlab.com"

    preregistered_runner_token_ssm_parameter_name = local.gitlab_runner_token_ssm_param_name
  }

  runner_worker_gitlab_pipeline = {
    pre_build_script  = <<EOT
        '''
        echo 'multiline 1'
        echo 'multiline 2'
        '''
        EOT
    post_build_script = "\"echo 'single line'\""
  }
  runner_worker_docker_options = {
    privileged = "true"
    volumes    = ["/cache", "/certs/client"]
  }

  runner_worker_docker_volumes_tmpfs = [
    {
      volume  = "/var/opt/cache",
      options = "rw,noexec"
    }
  ]

  runner_worker_docker_services_volumes_tmpfs = [
    {
      volume  = "/var/lib/mysql",
      options = "rw,noexec"
    }
  ]

  runner_worker_docker_machine_autoscaling_options = [
    # working 9 to 5 :)
    {
      periods    = ["* * 0-9,19-23 * * mon-fri *", "* * * * * sat,sun *"]
      idle_count = 0
      idle_time  = 60
      timezone   = "Asia/Singapore"
    }
  ]

  runner_cloudwatch = {
    enabled        = true
    retention_days = 3
  }

  runner_worker_docker_add_dind_volumes = true

  runner_networking = {
    allow_incoming_ping_security_group_ids = [data.aws_security_group.default.id]
    security_group_ids                     = var.security_group_ids
  }

  tags = {
    "tf-aws-gitlab-runner:name"              = "runner-default"
    "tf-aws-gitlab-runner:instancelifecycle" = "spot:yes"
  }
}
