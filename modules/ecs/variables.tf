variable "cluster_name" {
    type = string
}

variable "task_family" {
    type = string
}

variable "execution_role_arn" {
    type = string
}

variable "image_url" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "listerner_rule" {
    type = string
}

variable "backend_dns" {
    type = string
}

variable "auth_token" {
    type = string
}

variable "subnet" {
    type = list
}

variable "security_groups" {
    type = list
}

variable "efs_id" {
    type = string
}