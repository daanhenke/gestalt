# Example Terraform variables file
# Copy this to terraform.tfvars and fill in your actual values

# Kubernetes namespace for all services
namespace = "gestalt-services"

# Application name (used for service accounts and database names)
app_name = "gestalt"

# Developer accounts (customize as needed)
dev_accounts = ["alice", "bob", "charlie"]

# Application accounts (customize as needed)
app_accounts = ["gestalt-api", "gestalt-worker", "gestalt-scheduler"]

# Hostnames for services (replace with your actual domains)
nats_hostname = "nats.gestalt.chat"
minio_hostname = "minio.gestalt.chat"
dashboard_hostname = "dashboard.gestalt.chat"

# Email for Let's Encrypt certificate registration
letsencrypt_email = "daan@daan.vodka"

# IP whitelist for dev-only access (comma-separated CIDRs)
# Add your office/home IPs here
dev_ip_whitelist = "80.61.164.59/24"

# Static IP for PostgreSQL LoadBalancer (optional, for MetalLB users)
# Leave empty if not using MetalLB or static IPs
dev_loadbalancer_ip = ""

# Helm chart versions (optional - defaults will be used if not specified)
# nats_chart_version = "1.1.5"
# minio_chart_version = "5.0.14"
# postgres_chart_version = "13.2.24"
