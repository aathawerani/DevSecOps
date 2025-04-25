variable "deployment_id" {
  description = "Unique deployment identifier from Jenkins"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group (passed from Jenkins)"
  type        = string
}

variable "acr_name" {
  description = "Azure Container Registry name (passed from Jenkins)"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name for Terraform state (passed from Jenkins)"
  type        = string
}

variable "sql_server_name" {
  description = "Base name for SQL Server (will be combined with deployment_id)"
  type        = string
  default     = "sql-pg"
}

variable "sql_db_name" {
  description = "Name of the SQL Database"
  type        = string
  default     = "paymentgateway"
}

variable "sql_admin_username" {
  description = "Admin username for SQL Server"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "Admin password for SQL Server"
  type        = string
  sensitive   = true
}

variable "frontend_image" {
  description = "Docker image for frontend app"
  type        = string
}

variable "backend_image" {
  description = "Docker image for backend app"
  type        = string
}