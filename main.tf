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

data "rancher2_node_template" "rke_template" {
  name = var.node_template
}

resource "rancher2_cluster" "rke" {
  name = var.name
  description = var.description

  rke_config {
    network {
      plugin = var.kubernetes_network_plugin
    }
  }
}

resource "rancher2_node_pool" "node_pool" {
  cluster_id = rancher2_cluster.rke.id
  name = var.node_pool_name
  hostname_prefix = var.hostname_prefix
  node_template_id = data.rancher2_node_template.rke_template.id

  quantity = var.node_count
  control_plane = true
  etcd = true
  worker = true
}