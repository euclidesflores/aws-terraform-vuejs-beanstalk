provider "aws" {
  region = var.region
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com", "ec2.amazonaws.com", "managedupdates.elasticbeanstalk.amazonaws.com", "autoscaling.amazonaws.com", "elasticloadbalancing.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = file("${path.module}/key.pub")
}

resource "aws_iam_instance_profile" "beanstalk_profile" {
  name = "beanstalk_profile"
  role = aws_iam_role.beanstalk_service.name
}

resource "aws_iam_role" "beanstalk_service" {
  name               = "beanstalk-${var.app_name}-service"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  managed_policy_arns = [aws_iam_policy.autoscaling.arn, "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth", "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"]
}

resource "aws_iam_policy" "autoscaling" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "autoscaling:*",
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "cloudwatch:PutMetricAlarm",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeInstances",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribePlacementGroups",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcClassicLink"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "iam:CreateServiceLinkedRole",
        Resource = "*",
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "autoscaling.amazonaws.com"
          }
        }
      }
  ] })
}

resource "aws_elastic_beanstalk_application" "vueapp" {
  name        = var.app_name
  description = var.app_description
  tags = merge(
    { App = "${var.app_name}" },
    var.tags
  )

  appversion_lifecycle {
    service_role          = aws_iam_role.beanstalk_service.arn
    delete_source_from_s3 = true
  }
}

resource "aws_elastic_beanstalk_environment" "vueappenv" {
  name                = var.app_name
  application         = aws_elastic_beanstalk_application.vueapp.name
  solution_stack_name = var.stack_name

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.main.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", aws_subnet.public.*.id)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_profile.name
  }

  setting {
    name      = "AppSource"
    namespace = "aws:cloudformation:template:parameter"
    value     = "https://elasticbeanstalk-platform-assets-us-east-2.s3.us-east-2.amazonaws.com/stalks/eb_nodejs18_amazon_linux_2023_1.0.74.0_20230727192427/sampleapp/EBSampleApp-Nodejs.zip"
  }

  setting {
    name      = "EC2KeyName"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = aws_key_pair.deployer.key_name
  }
}

