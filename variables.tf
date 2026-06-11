variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "runner_ip" {
  type    = string
}

variable "sql_aad_admin_login" {
  description = "Microsoft Entra admin login"
  type        = string
}

variable "sql_aad_admin_object_id" {
  description = "Microsoft Entra admin object id"
  type        = string
}
