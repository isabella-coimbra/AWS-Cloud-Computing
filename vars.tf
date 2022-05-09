variable "cdirs_remote_access" {
  type = list
  description = "List of CIDR blocks"
}

variable "name_load_balancer" {
  type = string
  description = "The name of the LB"
}

variable "name_target" {
  type = string
  description = "The name of the target group"
}

variable "name_target_https" {
  type = string
  description = "The name of the target group with protocol HTTPS"
}

variable "name_autoscaling" {
  type = string
  description = "The name of the auto scaling"
}

variable "max_size"{
    description = "The maximum size of the Auto Scaling Group."
    type = number
}

variable "min_size"{
    description = "The minimum size of the Auto Scaling Group."
    type = number
}

#-------------------------------------------------------------------
# OPTIONAL VARIABLES
#-------------------------------------------------------------------

variable "region"{
    description = "Region of the instance"
    type = string
    default = "us-east-1"
}

variable "amis" {
    description = "AMI to use for the instance"
    type = map
    default = {
      "us-east-1" = "ami-026c8acd92718196b"
    }
}

variable "instance_type"{
    description = "Type of the instance"
    type = string
    default = "t2-micro"
}

variable "port"{
    description = "Number of the port to security group"
    type = number
    default = 22
}