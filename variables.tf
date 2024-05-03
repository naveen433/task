variable "aws_region" {
  description = "AWS region to use"
  type        = string
  default     = "us-west-1"
}

variable "aws_access_key" {
  description = "AWS Access Key ID for the target AWS account"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key for the target AWS account"
  type        = string
}

variable "aws_session_token" {
  description = "AWS Session Token for the target AWS account. Required only if authenticating using temporary credentials"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block to use for the VPC"
  type        = string
  default     = "192.170.0.0/20"
  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) <= 20 && tonumber(split("/", var.vpc_cidr)[1]) >= 16
    error_message = "CIDR size must be at least /20 and no larger than /16"
  }
}

variable "public_subnet_cidr" {
  type = list(string)
  description = "The IPv4 CIDR block for the public subnet"
  default     = ["192.170.1.0/24", "192.170.2.0/24", "192.170.3.0/24"]
  validation {
    condition     = tonumber(split("/", var.public_subnet_cidr)[1]) <= 28 && tonumber(split("/", var.public_subnet_cidr)[1]) >= 24
    error_message = "CIDR size must be at least /28 and no lorger than 24"
  }
}

variable "private_subnet_cidr" {
  type = list(string)
  description = "The IPv4 CIDR block for the private subnet"
  default     = ["192.170.1.0/24", "192.170.2.0/24", "192.170.3.0/24"]
   validation {
    condition     = tonumber(split("/", var.private_subnet_cidr)[1]) <= 28 && tonumber(split("/", var.private_subnet_cidr)[1]) >= 24
    error_message = "CIDR size must be at least /28 and no lorger than 24"
  }
}
