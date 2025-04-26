# Variables
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy to"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "The name of the storage account for Terraform state"
  type        = string
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
}

variable "sql_server_name" {
  description = "The name of the SQL server"
  type        = string
}

variable "sql_db_name" {
  description = "The name of the SQL database"
  type        = string
}

variable "sql_admin_username" {
  description = "The SQL admin username"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "The SQL admin password"
  type        = string
  sensitive   = true
}

variable "frontend_image" {
  description = "The frontend Docker image name"
  type        = string
}

variable "backend_image" {
  description = "The backend Docker image name"
  type        = string
}

variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
  sensitive   = true
}