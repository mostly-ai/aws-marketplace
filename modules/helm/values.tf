# These values are generated for easier local troubleshooting.
resource "local_sensitive_file" "main" {
  content  = local.values
  filename = "${path.module}/values.yaml"
}
