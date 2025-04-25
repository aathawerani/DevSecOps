output "sql_connection_string" {
  value = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.db.name};User ID=${azurerm_mssql_server.sql.administrator_login};Password=${azurerm_mssql_server.sql.administrator_login_password};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "sql_server_name" {
  value = azurerm_mssql_server.sql.name
}

output "sql_database_name" {
  value = azurerm_mssql_database.db.name
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}