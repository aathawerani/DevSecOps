variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "sql_db_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "sql_admin_username" {
  description = "Admin username for SQL Server"
  type        = string
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
