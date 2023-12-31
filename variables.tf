# BASIC variables
variable "my_ip" {
  description = "personal ip for ssh access and to access the app"
  default     = "0.0.0.0/0"
}
variable "app_port" {
  description = "The port for application"
  type        = number
  default     = 80
}
variable "image_name" {
  description = "Name of the image"
  type        = string
  default     = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/YOUR_IMAGE_NAME:latest"
}
variable "ecr_registry" {
  description = "Name of the image"
  type        = string
  default     = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com"
}
variable "key_pair_name" {
  description = "key pair name"
  default     = "myKey"
}
variable "region" {
  description = "aws region"
  default     = "eu-central-1"
}
# EC2 instances -----------------------
variable "instance_size" {
  description = "Ec2 Instance size"
  default     = "t3.nano"
}
# PORTS (dont' change) -----------------------
variable "ssh_port" {
  description = "The port the server will use for SSH"
  type        = number
  default     = 22
}
variable "https_port" {
  description = "The https port"
  type        = number
  default     = 443
}
