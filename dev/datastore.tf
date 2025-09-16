module "auroradb_cluster" {
  source = "../modules/datastore/aurora"

  # Basic Configuration
  name        = "${local.name_prefix}-auroradb-cluster-1"
  project     = var.project
  environment = var.environment

  # Network Configuration
  vpc_id            = module.vpc.vpc_id
  security_group_id = module.database_sg.security_group_id
  subnets           = module.vpc.database_subnets
  subnet_group_name = module.vpc.database_subnet_group_name

  # Database Configuration
  db_name     = var.project # Uses default from module if not specified
  db_username = var.project # Uses default from module if not specified

  # Security Configuration
  deletion_protection = true

  # Instance Configuration
  scaling_max_capacity = 1 # Default value, can be adjusted if needed
  instances = {
    1 = {} # Single instance for dev environment
  }
}


# create redis using module
module "redis" {
  source                             = "../modules/datastore/redis"
  security_group_id                  = module.redis_sg.security_group_id
  cluster_id                         = "${var.project}-${var.environment}-redis-cluster-1"
  availability_zone                  = module.vpc.azs[0]
  ssm_prefix                         = var.project
  subnet_group_name                  = module.vpc.database_subnet_group_name
  project                            = var.project
  environment                        = var.environment
  aws_cloudwatch_log_group_retention = 14
  num_nodes                          = 1
  node_type                          = "cache.t4g.micro"
}

module "rds_proxy" {
  source = "../modules/rds-proxy"

  project              = var.project
  environment          = var.environment
  database_subnets     = module.vpc.database_subnets
  auroradb_proxy_sg_id = module.auroradb_proxy_sg.security_group_id
  auroradb_cluster_id  = module.auroradb_cluster.cluster_id
}
