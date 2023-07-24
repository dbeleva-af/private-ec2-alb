variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  default     = "server"
}

variable "health_check_path" {
  description = "Health check path for the default target group"
  default     = "/"
}


