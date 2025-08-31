# Kubernetes Dashboard Configuration using Helm chart

# Kubernetes Dashboard Helm release
resource "helm_release" "kubernetes_dashboard" {
  name       = "gestalt-dashboard"
  namespace  = kubernetes_namespace.services.metadata[0].name
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  version    = var.dashboard_chart_version

  # Force recreation if there are conflicts
  force_update    = true
  cleanup_on_fail = true

  values = [
    yamlencode({
      app = {
        settings = {
          clusterName = "gestalt-cluster"
          itemsPerPage = 25
          resourceAutoRefreshTimeInterval = 5
        }

        ingress = {
          enabled = true
          hosts = [
            "${var.dashboard_hostname}"
          ]
          ingressClassName: "nginx"
          issuer = {
            name = "letsencrypt-prod"
            scope = "cluster"
          }
          annotations = {
            "acme.cert-manager.io/http01-edit-in-place" = "true"
          }
        }
      }

      api = {
        scaling = {
          replicas = 1
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.services]
}

# Dashboard Admin Service Account and ClusterRoleBinding
resource "kubernetes_service_account" "dashboard_admin" {
  metadata {
    name      = "gestalt-dashboard-admin"
    namespace = kubernetes_namespace.services.metadata[0].name
  }

  depends_on = [helm_release.kubernetes_dashboard]
}

resource "kubernetes_cluster_role_binding" "dashboard_admin" {
  metadata {
    name = "gestalt-dashboard-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard_admin.metadata[0].name
    namespace = kubernetes_service_account.dashboard_admin.metadata[0].namespace
  }

  depends_on = [kubernetes_service_account.dashboard_admin]
}

# Dashboard Admin Token Secret
resource "kubernetes_secret" "dashboard_admin_token" {
  metadata {
    name      = "gestalt-dashboard-admin-token"
    namespace = kubernetes_namespace.services.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.dashboard_admin.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [kubernetes_service_account.dashboard_admin]
}
