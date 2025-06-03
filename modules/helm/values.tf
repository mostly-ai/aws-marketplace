locals {
  helm_default_values = {
    global = {
      image = {
        mostlyRegistry = "709825985650.dkr.ecr.us-east-1.amazonaws.com/mostly-ai/platform"
      }
    },
    mostlyApp = {
      deployment = {
        awsProductCode = "7lynt012mo78turu5n6s8kbbc"
      }
    },
    combinedChart = {
      minio = {
        enabled = false
      }
    }
  }
}

resource "local_sensitive_file" "main" {
  content = yamlencode(
    provider::deepmerge::mergo(
      local.helm_default_values,
      var.helm_release_values,
      var.helm_release_secret_values
    )
  )
  filename = "${path.module}/values.yaml"
}
