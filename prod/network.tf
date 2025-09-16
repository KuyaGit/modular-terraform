module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.19.0"

  name = "${local.name_prefix}-vpc"

  cidr = "10.70.0.0/20"

  azs                 = ["ap-southeast-1a", "ap-southeast-1b"]
  public_subnets      = ["10.70.1.0/24", "10.70.2.0/24"]
  private_subnets     = ["10.70.3.0/24", "10.70.4.0/24"]
  database_subnets    = ["10.70.5.0/24", "10.70.6.0/24"]
  elasticache_subnets = ["10.70.7.0/24", "10.70.8.0/24"]

  create_database_subnet_group    = true
  create_elasticache_subnet_group = true

  enable_dhcp_options  = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                                 = true
  create_flow_log_cloudwatch_log_group            = true
  create_flow_log_cloudwatch_iam_role             = true
  flow_log_max_aggregation_interval               = 60
  flow_log_cloudwatch_log_group_retention_in_days = 1
}

module "database_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name        = "${local.name_prefix}-main-auroradb-sg"
  description = "Security group for main auroradb"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [{
    rule                     = "postgresql-tcp",
    source_security_group_id = module.private_services_sg.security_group_id
    },
    {
      rule                     = "postgresql-tcp",
      source_security_group_id = module.load_balancer_sg.security_group_id
    },
    {
      rule                     = "postgresql-tcp",
      source_security_group_id = module.auroradb_proxy_sg.security_group_id
    }
  ]
}

module "private_services_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name        = "${local.name_prefix}-private-services-sg"
  description = "Security group for private services"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["https-443-tcp", "http-80-tcp"]

  ingress_with_source_security_group_id = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow all incoming traffic from ALB security group to container service."
      source_security_group_id = module.load_balancer_sg.security_group_id
    }
  ]

  ingress_with_self = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Allow all incoming traffic from same security group to container service."
      # source_security_group_id = module.load_balancer_sg.security_group_id
      self = true
    }
  ]

  egress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp",
      source_security_group_id = module.database_sg.security_group_id
    },
    {
      rule                     = "redis-tcp",
      source_security_group_id = module.redis_sg.security_group_id
    },
    {
      rule                     = "postgresql-tcp",
      source_security_group_id = module.auroradb_proxy_sg.security_group_id
    }
  ]

  egress_with_self = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Allow all outgoing traffic on port"
      self        = true
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      description = "Allow outbound SMTP traffic to Google SMTP servers"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "load_balancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name        = "${local.name_prefix}-load-balancer-sg"
  description = "Security group for load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["https-443-tcp", "http-80-tcp"]

  egress_with_source_security_group_id = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow call to private services."
      source_security_group_id = module.private_services_sg.security_group_id
    },
    {
      rule                     = "redis-tcp",
      source_security_group_id = module.redis_sg.security_group_id
    },
  ]
}

module "redis_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name        = "${local.name_prefix}-main-redis-sg"
  description = "Security group for redis"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp",
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "http-80-tcp",
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  ingress_with_source_security_group_id = [{
    rule                     = "redis-tcp",
    source_security_group_id = module.private_services_sg.security_group_id
    },
    {
      rule                     = "redis-tcp",
      source_security_group_id = module.load_balancer_sg.security_group_id
  }]

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp",
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "http-80-tcp",
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "auroradb_proxy_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name        = "${local.name_prefix}-auroradb-proxy-sg"
  description = "Security group for auroradb proxy"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [{
    rule                     = "postgresql-tcp",
    source_security_group_id = module.private_services_sg.security_group_id
    },
    {
      rule                     = "postgresql-tcp",
      source_security_group_id = module.bastion.bastion_security_group_id
    }
  ]

  egress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp",
      source_security_group_id = module.database_sg.security_group_id
    }
  ]
}
