# --- 1. Create a Secrets Manager secret for DB credentials (if not already using one) ---
resource "aws_secretsmanager_secret" "aurora_db" {
  name = "${var.project}/${var.environment}/rds/credentials"
}

# read db_username and db_password from ssm parameter store
data "aws_ssm_parameter" "db_username" {
  name = "/tara/${var.environment}/rds/username"
}

data "aws_ssm_parameter" "db_password" {
  name = "/tara/${var.environment}/rds/password"
}

resource "aws_secretsmanager_secret_version" "aurora_db" {
  secret_id = aws_secretsmanager_secret.aurora_db.id
  secret_string = jsonencode({
    username = data.aws_ssm_parameter.db_username.value
    password = data.aws_ssm_parameter.db_password.value
  })
}

# --- 2. Create the RDS Proxy ---
resource "aws_db_proxy" "aurora" {
  name                   = "${var.project}-${var.environment}-aurora-proxy"
  engine_family          = "POSTGRESQL"
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_subnet_ids         = var.database_subnets
  vpc_security_group_ids = [var.auroradb_proxy_sg_id]
  require_tls            = false

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.aurora_db.arn
    iam_auth    = "DISABLED"
  }

  idle_client_timeout = 1800
  debug_logging       = false
}

# --- 3. Attach Proxy to Aurora Target Group ---
resource "aws_db_proxy_default_target_group" "aurora" {
  db_proxy_name = aws_db_proxy.aurora.name

  connection_pool_config {
    max_connections_percent      = 80
    max_idle_connections_percent = 50
    connection_borrow_timeout    = 120
  }
}

resource "aws_db_proxy_target" "aurora" {
  db_proxy_name         = aws_db_proxy.aurora.name
  target_group_name     = aws_db_proxy_default_target_group.aurora.name
  db_cluster_identifier = var.auroradb_cluster_id
}

# --- 4. IAM Role for RDS Proxy ---
resource "aws_iam_role" "rds_proxy" {
  name               = "${var.project}-${var.environment}-rds-proxy-role"
  assume_role_policy = data.aws_iam_policy_document.rds_proxy_assume_role.json
}

data "aws_iam_policy_document" "rds_proxy_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "rds_proxy_secrets" {
  role       = aws_iam_role.rds_proxy.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Save the proxy endpoint to ssm parameter store
resource "aws_ssm_parameter" "aurora_proxy_endpoint" {
  name  = "/tara/${var.environment}/rds/proxy-endpoint"
  type  = "SecureString"
  value = aws_db_proxy.aurora.endpoint
}
