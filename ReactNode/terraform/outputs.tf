output "sql_connection_string" {
  value = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.main.name};User ID=${azurerm_mssql_server.main.administrator_login};Password=${azurerm_mssql_server.main.administrator_login_password};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "sql_server_name" {
  value = azurerm_mssql_server.main.name
}

output "acr_name" {
  value = azurerm_container_registry.main.name
}