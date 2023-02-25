// Capture the Databricks workspace's URL.
output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

// Export the Databricks personal access token's value, for integration tests to run on.
output "databricks_token" {
  value     = databricks_token.pat.token_value
  sensitive = true
}