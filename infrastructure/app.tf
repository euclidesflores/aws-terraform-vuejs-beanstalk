provider "aws" {
  region = var.region
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "beanstalk_service" {
  name               = "beanstalk-${var.app_name}-service"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
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
}