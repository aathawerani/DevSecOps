terraform {
  backend "azurerm" {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = "tfstate"
    key                  = "paymentgateway-${var.resource_group_name}.tfstate"  # Unique per deployment
    subscription_id      = var.azure_subscription_id  # Add this line
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id  # Add this line
}

# Core Infrastructure Resources
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
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

resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.resource_group_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.resource_group_name}"
  sku_tier            = "Free"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_B2s"
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
  }

  tags = {
    environment = "production"
  }
}

# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# Kubernetes Deployments
resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend"
    labels = {
      app = "backend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          image = "${var.backend_image}:latest"
          name  = "backend-app"

          env {
            name  = "DB_CONNECTION_STRING"
            value = "Server=${azurerm_mssql_server.sql.fully_qualified_domain_name};Database=${azurerm_mssql_database.db.name};User Id=${var.sql_admin_username};Password=${var.sql_admin_password};"
          }

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.backend.metadata.0.labels.app
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    labels = {
      app = "frontend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          image = "${var.frontend_image}:latest"
          name  = "frontend-app"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.frontend.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

