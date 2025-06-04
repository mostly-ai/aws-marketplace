resource "helm_release" "main" {
  depends_on       = [local_sensitive_file.main]
  name             = var.service
  repository       = var.helm_release_repository
  version          = var.helm_release_version
  chart            = var.helm_release_chart
  namespace        = var.namespace
  create_namespace = true
  upgrade_install  = true
  values           = [local_sensitive_file.main.filename]
}
