variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "sql_admin_login" {
  description = "SQL admin login"
  type        = string
}

variable "sql_admin_password" {
  description = "SQL admin password"
  type        = string
  sensitive   = true
}