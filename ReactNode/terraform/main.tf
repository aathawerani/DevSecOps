terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"  # Separate RG for state files
    storage_account_name = "tfstate${substr(uuid(), 0, 8)}"  # Dynamic name
    container_name       = "tfstate"
    key                  = "paymentgateway.tfstate"  # Consistent name
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

variable "resource_group_name" {
  description = "Name of the resource group (passed from Jenkins)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "sql_server_name" {
  description = "Name of the SQL Server (passed from Jenkins)"
  type        = string
}

variable "sql_db_name" {
  description = "Name of the SQL Database (passed from Jenkins)"
  type        = string
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
  description = "Docker image for frontend app (passed from Jenkins)"
  type        = string
}

variable "backend_image" {
  description = "Docker image for backend app (passed from Jenkins)"
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

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_mssql_server" "sql" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.main.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "db" {
  name           = var.sql_db_name
  server_id      = azurerm_mssql_server.sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = "Basic"
  max_size_gb    = 2
  zone_redundant = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.resource_group_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.resource_group_name}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

# [Rest of your Kubernetes resources remain unchanged...]