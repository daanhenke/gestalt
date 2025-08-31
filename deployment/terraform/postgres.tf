# # PostgreSQL Helm release
# resource "helm_release" "postgres" {
#   name       = "postgres"
#   namespace  = kubernetes_namespace.services.metadata[0].name
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "postgresql"
#   version    = var.postgres_chart_version

#   values = [
#     yamlencode({
#       auth = {
#         postgresPassword = random_password.postgres_admin_password.result
#         database        = var.app_name
#       }

#       image = {
#         tag = "15.5.0-debian-11-r0"
#       }

#       primary = {
#         service = {
#           type = "ClusterIP"
#           ports = {
#             postgresql = 5432
#           }
#         }

#         persistence = {
#           enabled = true
#           size = "5Gi"
#         }

#         resources = {
#           limits = {
#             cpu = "500m"
#             memory = "512Mi"
#           }
#           requests = {
#             cpu = "100m"
#             memory = "128Mi"
#           }
#         }

#         initdb = {
#           scripts = {
#             "init.sql" = <<-EOF
#               ${join("\n", [
#                 for dev_account in var.dev_accounts :
#                 "-- Create dev user ${dev_account}\nCREATE USER ${dev_account} WITH PASSWORD '${random_password.dev_postgres_passwords[dev_account].result}';\nGRANT ALL PRIVILEGES ON DATABASE ${var.app_name} TO ${dev_account};"
#               ])}

#               ${join("\n", [
#                 for app_account in var.app_accounts :
#                 "-- Create app user ${app_account}\nCREATE USER ${app_account} WITH PASSWORD '${random_password.app_postgres_passwords[app_account].result}';\nGRANT ALL PRIVILEGES ON DATABASE ${var.app_name} TO ${app_account};"
#               ])}

#               -- Connect to app database and grant schema permissions
#               \c ${var.app_name};

#               ${join("\n", [
#                 for dev_account in var.dev_accounts :
#                 "GRANT ALL ON SCHEMA public TO ${dev_account};\nGRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${dev_account};\nGRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${dev_account};\nALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${dev_account};\nALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${dev_account};"
#               ])}

#               ${join("\n", [
#                 for app_account in var.app_accounts :
#                 "GRANT ALL ON SCHEMA public TO ${app_account};\nGRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${app_account};\nGRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${app_account};\nALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${app_account};\nALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${app_account};"
#               ])}
#             EOF
#           }
#         }
#       }

#       metrics = {
#         enabled = false
#       }
#     })
#   ]

#   depends_on = [kubernetes_namespace.services]
# }

# # PostgreSQL ClusterIP Service for dev access
# resource "kubernetes_service" "postgres_dev" {
#   metadata {
#     name      = "postgres-dev"
#     namespace = kubernetes_namespace.services.metadata[0].name
#     labels = {
#       app = "postgresql"
#     }
#   }

#   spec {
#     type = "ClusterIP"

#     selector = {
#       "app.kubernetes.io/name" = "postgresql"
#       "app.kubernetes.io/instance" = "postgres"
#     }

#     port {
#       name        = "postgres"
#       port        = 5432
#       target_port = 5432
#       protocol    = "TCP"
#     }
#   }

#   depends_on = [helm_release.postgres]
# }

# # NetworkPolicy to restrict PostgreSQL access
# resource "kubernetes_network_policy" "postgres_netpol" {
#   metadata {
#     name      = "postgres-netpol"
#     namespace = kubernetes_namespace.services.metadata[0].name
#   }

#   spec {
#     pod_selector {
#       match_labels = {
#         "app.kubernetes.io/name" = "postgresql"
#         "app.kubernetes.io/instance" = "postgres"
#       }
#     }

#     policy_types = ["Ingress"]

#     ingress {
#       from {
#         # Allow from same namespace
#         namespace_selector {
#           match_labels = {
#             name = kubernetes_namespace.services.metadata[0].name
#           }
#         }
#       }

#       from {
#         # Allow from dev IPs (if coming through LoadBalancer)
#         ip_block {
#           cidr = "10.0.0.0/8" # Adjust based on your cluster CIDR
#         }
#       }

#       ports {
#         protocol = "TCP"
#         port     = "5432"
#       }
#     }
#   }

#   depends_on = [helm_release.postgres]
# }
