resource "aws_ssm_parameter" "dealer_api_key" {
  name  = "/${var.project}/${var.environment}/pc-api/dealer-api-key"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "dealer_url" {
  name  = "/${var.project}/${var.environment}/pc-api/dealer-url"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

# Firebase App Check Debug Token
resource "aws_ssm_parameter" "firebase_app_check_debug_token" {
  name  = "/${var.project}/${var.environment}/firebase/app-check/debug-token"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

# iOS Device Check Private Key
resource "aws_ssm_parameter" "firebase_app_check_ios_private_key" {
  name  = "/${var.project}/${var.environment}/firebase/app-check/ios/private-key"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

# iOS Key ID
resource "aws_ssm_parameter" "firebase_app_check_ios_key_id" {
  name  = "/${var.project}/${var.environment}/firebase/app-check/ios/key-id"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

# iOS Team ID
resource "aws_ssm_parameter" "firebase_app_check_ios_team_id" {
  name  = "/${var.project}/${var.environment}/firebase/app-check/ios/team-id"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

# Web reCAPTCHA Site Key
resource "aws_ssm_parameter" "firebase_app_check_recaptcha_site_key" {
  name  = "/${var.project}/${var.environment}/firebase/app-check/web/recaptcha-site-key"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "debug" {
  name  = "/${var.project}/${var.environment}/debug"
  type  = "SecureString"
  value = "true"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "allowed_origins" {
  name  = "/${var.project}/${var.environment}/allowed-origins"
  type  = "SecureString"
  value = "https://dev-superapp.pcdsi.ph/graphql,http://${module.core_service.alb_dns_name}/graphql,http://localhost:8080/graphql"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "firebase_project_id" {
  name  = "/${var.project}/${var.environment}/FIREBASE_PROJECT_ID"
  type  = "SecureString"
  value = "ChangeMe"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "firebase_private_key" {
  name  = "/${var.project}/${var.environment}/FIREBASE_PRIVATE_KEY"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "firebase_client_email" {
  name  = "/${var.project}/${var.environment}/FIREBASE_CLIENT_EMAIL"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "firebase_api_key" {
  name  = "/${var.project}/${var.environment}/firebase-api-key"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "firebase_app_check_enabled" {
  name  = "/${var.project}/${var.environment}/firebase/app-check/enabled"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "pc_api_sms_api_key" {
  name  = "/${var.project}/${var.environment}/pc-api/sms-api-key"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "pc_api_sms_url" {
  name  = "/${var.project}/${var.environment}/pc-api/sms-url"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

# Dynatrace API URL parameter
resource "aws_ssm_parameter" "dt_api_url" {
  name        = "/${var.project}/${var.environment}/dynatrace/api/url"
  description = "Dynatrace API URL"
  type        = "String"
  value       = "ChangeMe"
  tags = {
    Environment = var.environment
    Service     = "dynatrace"
  }

  lifecycle {
    ignore_changes = [value]
  }
}

# Dynatrace API Token parameter
resource "aws_ssm_parameter" "dt_api_token" {
  name        = "/${var.project}/${var.environment}/dynatrace/api/token"
  description = "Dynatrace API Token"
  type        = "SecureString"
  value       = "ChangeMe"
  tags = {
    Environment = var.environment
    Service     = "dynatrace"
  }

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "dt_id" {
  name  = "/${var.project}/${var.environment}/dynatrace/id"
  type  = "SecureString"
  value = "ChangeMe"
  tags = {
    Environment = var.environment
    Service     = "dynatrace"
  }

  lifecycle {
    ignore_changes = [value]
  }
}

# create ssm parameter for the token installer
resource "aws_ssm_parameter" "dt_activegate_token" {
  name  = "/${var.project}/${var.environment}/dynatrace/activegate/token"
  type  = "SecureString"
  value = "ChangeMe"

  tags = {
    Environment = var.environment
    Service     = "dynatrace"
  }

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "pc_api_service_url" {
  name  = "/${var.project}/${var.environment}/pc-api/service-url"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "pc_api_service_api_key" {
  name  = "/${var.project}/${var.environment}/pc-api/service-api-key"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "smtp_email" {
  name  = "/${var.project}/${var.environment}/smtp/smtp-email"
  type  = "String"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "smtp_password" {
  name  = "/${var.project}/${var.environment}/smtp/smtp-password"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "del_req_receiver_email" {
  name  = "/${var.project}/${var.environment}/smtp/del-req-receiver-email"
  type  = "String"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

# GrowthBook API Host
resource "aws_ssm_parameter" "growthbook_api_host" {
  name  = "/${var.project}/${var.environment}/growthbook/api-host"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

# GrowthBook Client Key
resource "aws_ssm_parameter" "growthbook_client_key" {
  name  = "/${var.project}/${var.environment}/growthbook/client-key"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

# GrowthBook Enable Dev Mode
resource "aws_ssm_parameter" "growthbook_enable_dev_mode" {
  name  = "/${var.project}/${var.environment}/growthbook/enable-dev-mode"
  type  = "String"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}

# Google Maps API Key
resource "aws_ssm_parameter" "google_maps_api_key" {
  name  = "/${var.project}/${var.environment}/google/maps/api-key"
  type  = "SecureString"
  value = "ChangeMe"

  lifecycle {
    ignore_changes = [value]
  }
}
