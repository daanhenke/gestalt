# # NATS Configuration using Helm chart

# # NATS Helm release
# resource "helm_release" "nats" {
#   name       = "nats"
#   namespace  = kubernetes_namespace.services.metadata[0].name
#   repository = "https://nats-io.github.io/k8s/helm/charts/"
#   chart      = "nats"
#   version    = var.nats_chart_version

#   values = [
#     yamlencode({
#       config = {
#         jetstream = {
#           enabled = true
#           fileStore = {
#             pvc = {
#               size = "10Gi"
#             }
#           }
#           memStore = {
#             maxSize = "1Gi"
#           }
#         }

#         cluster = {
#           enabled = false
#           replicas = 2
#         }

#         nats = {
#           port = 4222
#         }

#         websocket = {
#           enabled = false
#         }

#         mqtt = {
#           enabled = false
#         }

#         monitor = {
#           enabled = true
#           port = 8222
#         }
#       }

#       auth = {
#         enabled = true
#         basic = {
#           users = concat(
#             [
#               {
#                 user = "admin"
#                 password = random_password.nats_admin_password.result
#               }
#             ],
#             [
#               for dev_account in var.dev_accounts : {
#                 user = dev_account
#                 password = random_password.dev_nats_passwords[dev_account].result
#               }
#             ],
#             [
#               for app_account in var.app_accounts : {
#                 user = app_account
#                 password = random_password.app_nats_passwords[app_account].result
#               }
#             ]
#           )
#         }
#       }

#       natsBox = {
#         enabled = true
#       }

#       service = {
#         type = "ClusterIP"
#       }

#       resources = {
#         limits = {
#           cpu = "500m"
#           memory = "512Mi"
#         }
#         requests = {
#           cpu = "100m"
#           memory = "128Mi"
#         }
#       }
#     })
#   ]

#   depends_on = [kubernetes_namespace.services]
# }

# # ConfigMap for TCP services (required for NATS TCP ingress)
# resource "kubernetes_config_map" "tcp_services" {
#   metadata {
#     name      = "tcp-services"
#     namespace = kubernetes_namespace.services.metadata[0].name
#   }

#   data = {
#     "4222" = "${kubernetes_namespace.services.metadata[0].name}/nats:4222"
#   }
# }

# # NATS Monitor Ingress (for HTTP monitoring dashboard)
# resource "kubernetes_ingress_v1" "nats_monitor" {
#   metadata {
#     name      = "nats-monitor"
#     namespace = kubernetes_namespace.services.metadata[0].name
#     annotations = {
#       "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
#       "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
#     }
#   }

#   spec {
#     ingress_class_name = "nginx"

#     tls {
#       hosts = ["monitor.${var.nats_hostname}"]
#       secret_name = "nats-monitor-tls"
#     }

#     rule {
#       host = "monitor.${var.nats_hostname}"

#       http {
#         path {
#           path = "/"
#           path_type = "Prefix"

#           backend {
#             service {
#               name = "nats"
#               port {
#                 number = 8222
#               }
#             }
#           }
#         }
#       }
#     }
#   }

#   depends_on = [helm_release.nats]
# }

resource "helm_release" "nats" {
  name       = "nats"
  repository = "https://nats-io.github.io/k8s/helm/charts/"
  chart      = "nats"
  namespace  = kubernetes_namespace.services.metadata[0].name
  version    = "1.3.13" # check with `helm search repo nats`

  create_namespace = true

  values = [
    yamlencode({
      config = {
        cluster = {
          enabled = false
        }
      }

      service = {
        ports = {
          monitor = {
            enabled = true
          }
        }
        merge = {
          spec = {
            type = "NodePort"
            ports = [
              { name = "nats", port = 4222, targetPort = 4222, nodePort = 30422 },
              { name = "monitor", port = 8222, targetPort = 8222, nodePort = 30822 }
            ]
          }
        }
      }
    })
  ]
}
