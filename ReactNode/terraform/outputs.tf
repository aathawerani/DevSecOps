# Outputs

output "frontend_url" {
  value = "http://${kubernetes_service.frontend.status.0.load_balancer.0.ingress.0.ip}"
}

output "sql_connection_string" {
  value     = "Server=${azurerm_mssql_server.sql.fully_qualified_domain_name};Database=${azurerm_mssql_database.db.name};User Id=${var.sql_admin_username};Password=${var.sql_admin_password};"
  sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "sql_server_name" {
  value = azurerm_mssql_server.sql.name
}

output "sql_database_name" {
  value = azurerm_mssql_database.db.name
}