output "values_file" {
  value     = local_sensitive_file.main.content
  sensitive = true
}
