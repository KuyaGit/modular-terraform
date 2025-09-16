module "cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.13.0"

  # Basic Configuration
  name           = var.name
  engine         = "aurora-postgresql"
  engine_version = "16.6"
  engine_mode    = "provisioned"

  # Network Configuration
  vpc_id                 = var.vpc_id
  subnets                = var.subnets
  db_subnet_group_name   = var.subnet_group_name
  create_security_group  = false
  vpc_security_group_ids = [var.security_group_id]

  # Database Configuration
  database_name               = var.db_name
  master_username             = var.db_username
  master_password             = random_password.master_password.result
  manage_master_user_password = false
  # manage_master_user_password                   = true # Disable til application is ready to handle password rotation with no downtime
  # master_user_password_rotation_automatically_after_days = 30

  # Instance Configuration
  instance_class = "db.serverless"
  instances      = var.instances
  serverlessv2_scaling_configuration = {
    min_capacity = var.scaling_min_capacity
    max_capacity = var.scaling_max_capacity
  }

  # Parameter Groups
  create_db_parameter_group                  = true
  create_db_cluster_parameter_group          = true
  db_parameter_group_name                    = "${var.project}-postgres16"
  db_cluster_parameter_group_name            = "${var.project}-postgres16-cluster"
  db_parameter_group_use_name_prefix         = false
  db_cluster_parameter_group_use_name_prefix = false
  db_parameter_group_family                  = "aurora-postgresql16"
  db_cluster_parameter_group_family          = "aurora-postgresql16"

  # Backup and Maintenance
  preferred_maintenance_window = ""
  preferred_backup_window      = ""
  skip_final_snapshot          = true

  # Monitoring and Security
  storage_encrypted            = true
  deletion_protection          = var.deletion_protection
  monitoring_interval          = 60
  performance_insights_enabled = true
  apply_immediately            = true
}

# Generate a random password for initial setup
resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# Store DB connection details in SSM Parameter Store
resource "aws_ssm_parameter" "db_host" {
  name        = "/tara/${var.environment}/rds/host"
  description = "Aurora cluster endpoint"
  type        = "SecureString"
  value       = module.cluster.cluster_endpoint
}

resource "aws_ssm_parameter" "db_name" {
  name        = "/tara/${var.environment}/rds/database"
  description = "Aurora database name"
  type        = "SecureString"
  value       = var.db_name
}

resource "aws_ssm_parameter" "db_username" {
  name        = "/tara/${var.environment}/rds/username"
  description = "Aurora master username"
  type        = "SecureString"
  value       = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/tara/${var.environment}/rds/password"
  description = "Aurora master password"
  type        = "SecureString"
  value       = random_password.master_password.result
}
