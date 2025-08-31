# Variables for the Terraform configuration

variable "namespace" {
  description = "Kubernetes namespace for all services"
  type        = string
  default     = "gestalt-services"
}

variable "app_name" {
  description = "Application name used for service accounts and database names"
  type        = string
  default     = "gestalt"
}

variable "dev_accounts" {
  description = "List of developer account names"
  type        = list(string)
  default     = ["dev1", "dev2"]
}

variable "app_accounts" {
  description = "List of application account names"
  type        = list(string)
  default     = ["gestalt-api", "gestalt-worker"]
}

variable "nats_hostname" {
  description = "Hostname for NATS service"
  type        = string
  default     = "nats.gestalt.chat"
}

variable "minio_hostname" {
  description = "Hostname for MinIO service"
  type        = string
  default     = "minio.gestalt.chat"
}

variable "dashboard_hostname" {
  description = "Hostname for Kubernetes Dashboard"
  type        = string
  default     = "dashboard.gestalt.chat"
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt certificate registration"
  type        = string
}

variable "dev_ip_whitelist" {
  description = "Comma-separated list of IP addresses/CIDRs allowed for dev access"
  type        = string
  default     = "127.0.0.1/32,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
}

variable "dev_loadbalancer_ip" {
  description = "Static IP address for PostgreSQL LoadBalancer (if using MetalLB)"
  type        = string
  default     = ""
}

# Helm chart versions
variable "nats_chart_version" {
  description = "NATS Helm chart version"
  type        = string
  default     = "1.1.5"
}

variable "minio_chart_version" {
  description = "MinIO Helm chart version"
  type        = string
  default     = "17.0.21"
}

variable "postgres_chart_version" {
  description = "PostgreSQL Helm chart version"
  type        = string
  default     = "13.2.24"
}

variable "dashboard_chart_version" {
  description = "Kubernetes Dashboard Helm chart version"
  type        = string
  default     = "7.0.0"
}
