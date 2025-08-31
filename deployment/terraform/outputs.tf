# Outputs for service credentials and connection information

output "nats_credentials" {
  description = "NATS service credentials"
  value = {
    admin_password = random_password.nats_admin_password.result
    dev_accounts = {
      for dev_account in var.dev_accounts : dev_account => {
        username = dev_account
        password = random_password.dev_nats_passwords[dev_account].result
      }
    }
    app_accounts = {
      for app_account in var.app_accounts : app_account => {
        username = app_account
        password = random_password.app_nats_passwords[app_account].result
      }
    }
    hostname       = var.nats_hostname
    port          = 4222
    monitor_url   = "https://monitor.${var.nats_hostname}"
  }
  sensitive = true
}

output "minio_credentials" {
  description = "MinIO service credentials"
  value = {
    root_user        = "admin"
    root_password    = random_password.minio_root_password.result
    dev_accounts = {
      for dev_account in var.dev_accounts : dev_account => {
        username = dev_account
        password = random_password.dev_minio_passwords[dev_account].result
      }
    }
    app_accounts = {
      for app_account in var.app_accounts : app_account => {
        username = app_account
        password = random_password.app_minio_passwords[app_account].result
      }
    }
    api_url          = "https://${var.minio_hostname}"
    console_url      = "https://console.${var.minio_hostname}"
    public_bucket_url = "https://buckets.${var.minio_hostname}/public"
  }
  sensitive = true
}

output "postgres_credentials" {
  description = "PostgreSQL service credentials"
  value = {
    postgres_user     = "postgres"
    postgres_password = random_password.postgres_admin_password.result
    dev_accounts = {
      for dev_account in var.dev_accounts : dev_account => {
        username = dev_account
        password = random_password.dev_postgres_passwords[dev_account].result
      }
    }
    app_accounts = {
      for app_account in var.app_accounts : app_account => {
        username = app_account
        password = random_password.app_postgres_passwords[app_account].result
      }
    }
    database          = var.app_name
    internal_host     = "postgres-postgresql.${var.namespace}.svc.cluster.local"
    internal_port     = 5432
    dev_access_note   = "Use LoadBalancer service 'postgres-dev' for external access"
  }
  sensitive = true
}

output "connection_strings" {
  description = "Connection strings for applications"
  value = {
    nats_urls = {
      for app_account in var.app_accounts : app_account => 
      "nats://${app_account}:${random_password.app_nats_passwords[app_account].result}@${var.nats_hostname}:4222"
    }
    postgres_urls = {
      for app_account in var.app_accounts : app_account => 
      "postgresql://${app_account}:${random_password.app_postgres_passwords[app_account].result}@postgres-postgresql.${var.namespace}.svc.cluster.local:5432/${var.app_name}?sslmode=require"
    }
    minio_urls = {
      for app_account in var.app_accounts : app_account => 
      "https://${app_account}:${random_password.app_minio_passwords[app_account].result}@${var.minio_hostname}"
    }
  }
  sensitive = true
}

output "dashboard_info" {
  description = "Kubernetes Dashboard access information"
  value = {
    url = "https://${var.dashboard_hostname}"
    admin_token_secret = "gestalt-dashboard-admin-token"
    namespace = var.namespace
    access_note = "Dashboard is IP-whitelisted for dev access only"
    token_command = "kubectl get secret gestalt-dashboard-admin-token -n ${var.namespace} -o jsonpath='{.data.token}' | base64 -d"
  }
  sensitive = false
}