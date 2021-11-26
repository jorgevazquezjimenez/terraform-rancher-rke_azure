# Configure Rancher provider
terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
    }
  }
}

provider "rancher2" {
  api_url = "https://sanes-rancher.westeurope.cloudapp.azure.com"
  access_key = var.access_key
  secret_key = var.secret_key
  insecure = true
}

module "rke_cluster" {
  source = "app.terraform.io/georgevazj-lab/rke_cluster/rancher2"
  version = "0.0.4"

  api_url = "https://sanes-rancher.westeurope.cloudapp.azure.com"
  access_key = var.access_key
  secret_key = var.secret_key
  description = var.description
  name = var.name
  kubernetes_network_plugin = var.kubernetes_network_plugin
}

module "node_pool" {
  source  = "app.terraform.io/georgevazj-lab/node_pool/rancher2"
  version = "0.0.3"

  api_url = "https://sanes-rancher.westeurope.cloudapp.azure.com"
  name = var.node_pool_name
  access_key = var.access_key
  secret_key = var.secret_key
  cluster_id = module.rke_cluster.cluster_id
  description = var.description
  node_template = var.node_template_name
  hostname_prefix = var.hostname_prefix
  is_control_plane = true
  is_worker = true
  is_etcd = true
  quantity = var.quantity
}

resource "rancher2_cluster_sync" "sync" {
  cluster_id = module.rke_cluster.cluster_id
  node_pool_ids = [module.node_pool.node_pool_id]
}

resource "rancher2_namespace" "cattle-monitoring" {
  name       = "cattle-monitoring-system"
  project_id = rancher2_cluster_sync.sync.system_project_id
}

resource "rancher2_app" "monitoring" {
  catalog_name     = "Partners"
  name             = "rancher-monitoring-crd"
  project_id       = rancher2_cluster_sync.sync.system_project_id
  target_namespace = rancher2_namespace.cattle-monitoring.id
  template_name    = "rancher-monitoring-crd"
  description = "Rancher monitoring chart"
  wait = true
}

module "project" {
  source  = "app.terraform.io/georgevazj-lab/project/rancher"
  version = "0.0.1"

  access_key = var.access_key
  api_url    = var.api_url
  cluster_id = rancher2_cluster_sync.sync.cluster_id
  name       = var.project_name
  secret_key = var.secret_key
}

resource "rancher2_namespace" "app_namespace" {
  name       = "sampleapp"
  project_id = module.project.id
}