# Generate key pair
resource "tls_private_key" "bastion" {
  algorithm = "ED25519"
}

# Store public key in AWS
resource "aws_key_pair" "bastion" {
  key_name   = "${var.project}-${var.environment}-bastion"
  public_key = tls_private_key.bastion.public_key_openssh
}

# Store private key in Parameter Store (encrypted)
resource "aws_ssm_parameter" "bastion_private_key" {
  name        = "/tara/${var.environment}/bastion/ssh_private_key"
  description = "Private key for bastion host"
  type        = "SecureString"
  value       = tls_private_key.bastion.private_key_openssh
}

module "bastion" {
  source = "../modules/bastion"

  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnets[0]

  allowed_ssh_cidrs = [
    "54.151.230.9/32",    # IP Range of WC VPN
    "203.177.135.194/32", # IP of Kent
  ]                       # TODO: Replace with your allowed IPs
  key_name = aws_key_pair.bastion.key_name
}

# Allow bastion to access RDS
resource "aws_security_group_rule" "rds_from_bastion" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.bastion.bastion_security_group_id
  security_group_id        = module.database_sg.security_group_id
}
