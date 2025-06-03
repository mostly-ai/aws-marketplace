output "values_file_content" {
  value     = local_sensitive_file.main.content
  sensitive = true
}
