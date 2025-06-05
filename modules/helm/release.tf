resource "helm_release" "main" {
  # This depends_on block ensures that the local_sensitive_file is created before the helm_release.
  # This way the values can be viewed even if the helm_release fails.
  # We do not use this values file directly as it would cause helm_release to destroy this resource instead of updating it.
  depends_on          = [local_sensitive_file.main]
  name                = var.service
  repository          = var.helm_release_repository
  repository_username = var.helm_repository_auth_user
  repository_password = var.helm_repository_auth_password
  version             = var.helm_release_version
  chart               = var.helm_release_chart
  timeout             = var.helm_release_timeout
  namespace           = var.namespace
  create_namespace    = true
  upgrade_install     = true
  values              = [local.values]
}

locals {
  values = yamlencode(
    provider::deepmerge::mergo(
      var.helm_release_values.values,
      var.helm_release_secret_values.values
    )
  )
}
