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

variable "vnet_id" {
  description = "Virtual Network ID"
  type        = string
}
variable "private_endpoint_subnet_id" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "sql_server_id" {
  type = string
}

variable "acr_id" {
  type = string
}

variable "managed_identity_principal_id" {
  type = string
}