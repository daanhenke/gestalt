# MinIO Configuration using Helm chart

# MinIO Helm release
resource "helm_release" "minio" {
  name       = "minio"
  namespace  = kubernetes_namespace.services.metadata[0].name
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "minio"
  version    = var.minio_chart_version

  values = [
    yamlencode({
      auth = {
        rootUser     = "admin"
        rootPassword = random_password.minio_root_password.result
      }

      defaultBuckets = "public,private"

      ingress = {
        enabled = true
        ingressClassName = "nginx"
        pathType = "Prefix"
        hostname = "${var.minio_hostname}"
        tls = true
        annotations = {
          "acme.cert-manager.io/http01-edit-in-place" = "true"
          "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
        }
      }

      console = {
        enabled = true
        ingress = {
          enabled = true
          tls = true
          pathType = "Prefix"
          ingressClassName = "nginx"
          hostname = "console.${var.minio_hostname}"
          annotations = {
            "acme.cert-manager.io/http01-edit-in-place" = "true"
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
          }
        }
      }

      tls = {
        enabled = true
      }
    })
  ]

  depends_on = [kubernetes_namespace.services]
}
