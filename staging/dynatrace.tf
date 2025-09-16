resource "aws_iam_role" "dynatrace" {
  name = "${var.project}-${var.environment}-dynatrace"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::509560245411:root"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.dynatrace_external_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "dynatrace_monitoring" {
  name = "${var.project}-${var.environment}-dynatrace-policy"
  role = aws_iam_role.dynatrace.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "DynatraceMonitoringPolicy",
        Effect = "Allow",
        Action = [
          "acm-pca:ListCertificateAuthorities",
          "apigateway:GET",
          "apprunner:ListServices",
          "appstream:DescribeFleets",
          "appsync:ListGraphqlApis",
          "athena:ListWorkGroups",
          "autoscaling:DescribeAutoScalingGroups",
          "cloudformation:ListStackResources",
          "cloudfront:ListDistributions",
          "cloudhsm:DescribeClusters",
          "cloudsearch:DescribeDomains",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "codebuild:ListProjects",
          "datasync:ListTasks",
          "dax:DescribeClusters",
          "directconnect:DescribeConnections",
          "dms:DescribeReplicationInstances",
          "dynamodb:ListTables",
          "dynamodb:ListTagsOfResource",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeNatGateways",
          "ec2:DescribeSpotFleetRequests",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeVolumes",
          "ec2:DescribeVpnConnections",
          "ecs:ListClusters",
          "eks:ListClusters",
          "elasticache:DescribeCacheClusters",
          "elasticbeanstalk:DescribeEnvironmentResources",
          "elasticbeanstalk:DescribeEnvironments",
          "elasticfilesystem:DescribeFileSystems",
          "elasticloadbalancing:DescribeInstanceHealth",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticmapreduce:ListClusters",
          "elastictranscoder:ListPipelines",
          "es:ListDomainNames",
          "events:ListEventBuses",
          "firehose:ListDeliveryStreams",
          "fsx:DescribeFileSystems",
          "gamelift:ListFleets",
          "glue:GetJobs",
          "inspector:ListAssessmentTemplates",
          "kafka:ListClusters",
          "kinesis:ListStreams",
          "kinesisanalytics:ListApplications",
          "kinesisvideo:ListStreams",
          "lambda:ListFunctions",
          "lambda:ListTags",
          "lex:GetBots",
          "logs:DescribeLogGroups",
          "mediaconnect:ListFlows",
          "mediaconvert:DescribeEndpoints",
          "mediapackage-vod:ListPackagingConfigurations",
          "mediapackage:ListChannels",
          "mediatailor:ListPlaybackConfigurations",
          "opsworks:DescribeStacks",
          "qldb:ListLedgers",
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds:DescribeEvents",
          "rds:ListTagsForResource",
          "redshift:DescribeClusters",
          "robomaker:ListSimulationJobs",
          "route53:ListHostedZones",
          "route53resolver:ListResolverEndpoints",
          "s3:ListAllMyBuckets",
          "sagemaker:ListEndpoints",
          "sns:ListTopics",
          "sqs:ListQueues",
          "storagegateway:ListGateways",
          "sts:GetCallerIdentity",
          "swf:ListDomains",
          "tag:GetResources",
          "tag:GetTagKeys",
          "transfer:ListServers",
          "workmail:ListOrganizations",
          "workspaces:DescribeWorkspaces"
        ],
        Resource = "*"
      }
    ]
  })
}

# resource "aws_security_group" "activegate_sg" {
#   name        = "${var.project}-${var.environment}-dynatrace-activegate-sg"
#   description = "Allow ActiveGate traffic"

#   vpc_id = module.vpc.vpc_id

#   ingress {
#     from_port   = 9999
#     to_port     = 9999
#     protocol    = "tcp"
#     cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# Create an ec2 server with cost effective linux image
# for dynatrace activegate and collector of opentelemetry
# get the sensitive data from ssm
# resource "aws_instance" "dynatrace" {
#   ami           = "ami-02f7b163d79aae0cb"
#   instance_type = "t3.micro"

#   vpc_security_group_ids      = [aws_security_group.activegate_sg.id]
#   subnet_id                   = module.vpc.public_subnets[0]
#   associate_public_ip_address = false

#   root_block_device {
#     volume_type           = "gp3"
#     volume_size           = 20
#     encrypted             = true
#     delete_on_termination = true
#   }

#   user_data = <<-EOF
#               #!/bin/bash
#               yum update -y
#               yum install -y wget

#               wget "https://${aws_ssm_parameter.dt_id.value}.live.dynatrace.com/api/v1/deployment/installer/gateway/unix/latest?Api-Token=${aws_ssm_parameter.dt_activegate_token.value}" -O Dynatrace-ActiveGate.sh
#               chmod +x Dynatrace-ActiveGate.sh
#               ./Dynatrace-ActiveGate.sh
#     EOF
#   tags = {
#     Name = "${var.project}-${var.environment}-dynatrace-activegate"
#   }
# }
