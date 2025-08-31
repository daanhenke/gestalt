terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  
  required_version = ">= 1.0"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
  
  # Add Helm repositories
  repository_config_path = "${path.module}/.helm/repositories.yaml"
  repository_cache       = "${path.module}/.helm"
}

# Create namespace for all services
resource "kubernetes_namespace" "services" {
  metadata {
    name = var.namespace
  }
}

# Admin passwords for services
resource "random_password" "nats_admin_password" {
  length  = 16
  special = true
}

resource "random_password" "minio_root_password" {
  length  = 16
  special = true
}

resource "random_password" "postgres_admin_password" {
  length  = 16
  special = true
}

# Developer account passwords
resource "random_password" "dev_nats_passwords" {
  for_each = toset(var.dev_accounts)
  length   = 16
  special  = true
}

resource "random_password" "dev_minio_passwords" {
  for_each = toset(var.dev_accounts)
  length   = 16
  special  = true
}

resource "random_password" "dev_postgres_passwords" {
  for_each = toset(var.dev_accounts)
  length   = 16
  special  = true
}

# Application account passwords
resource "random_password" "app_nats_passwords" {
  for_each = toset(var.app_accounts)
  length   = 16
  special  = true
}

resource "random_password" "app_minio_passwords" {
  for_each = toset(var.app_accounts)
  length   = 16
  special  = true
}

resource "random_password" "app_postgres_passwords" {
  for_each = toset(var.app_accounts)
  length   = 16
  special  = true
}