module "loggings" {
  source = "./modules/logging"
  loggings = [
    {
      name              = "app"
      group_name        = "app-log-group"
      retention_in_days = 1
      stream_name       = "app-stream"
    },
    {
      name              = "api"
      group_name        = "api-log-group"
      retention_in_days = 1
      stream_name       = "api-stream"
    }
  ]
}
