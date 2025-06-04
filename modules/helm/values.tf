resource "local_sensitive_file" "main" {
  content = yamlencode(
    provider::deepmerge::mergo(
      var.helm_release_values.values,
      var.helm_release_secret_values.values
    )
  )
  filename = "${path.module}/values.yaml"
}
