variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-2"
}

variable "app_name" {
  type        = string
  description = "application name"
  default     = "vueapp"
}

variable "app_description" {
  type        = string
  description = "App description"
  default     = "A Vue app"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    "Env"      = "Dev"
    "Provider" = "elastic beanstalk"
  }
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  default = 3
}

variable "cidr_blocks" {
  type = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24"
  ]
}

variable "stack_name" {
  default = "64bit Amazon Linux 2 v5.8.3 running Node.js 18"
}
