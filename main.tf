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

data "rancher2_node_template" "controlplane_template" {
  name = var.control_node_template
}

data "rancher2_node_template" "workers_template" {
  name = var.workers_node_template
}

resource "rancher2_cluster" "rke" {
  name = var.name
  description = var.description

  rke_config {
    network {
      plugin = var.kubernetes_network_plugin
    }
  }

  enable_cluster_monitoring = true
  cluster_monitoring_input {
    answers = {
      "exporter-kubelets.https" = true
      "exporter-node.enabled" = true
      "exporter-node.ports.metrics.port" = 9796
      "exporter-node.resources.limits.cpu" = "200m"
      "exporter-node.resources.limits.memory" = "200Mi"
      "grafana.persistence.enabled" = false
      "grafana.persistence.size" = "10Gi"
      "grafana.persistence.storageClass" = "default"
      "operator.resources.limits.memory" = "500Mi"
      "prometheus.persistence.enabled" = "false"
      "prometheus.persistence.size" = "50Gi"
      "prometheus.persistence.storageClass" = "default"
      "prometheus.persistent.useReleaseName" = "true"
      "prometheus.resources.core.limits.cpu" = "1000m",
      "prometheus.resources.core.limits.memory" = "1500Mi"
      "prometheus.resources.core.requests.cpu" = "750m"
      "prometheus.resources.core.requests.memory" = "750Mi"
      "prometheus.retention" = "12h"
    }
  }
}

resource "rancher2_node_pool" "etcd_pool" {
  cluster_id = rancher2_cluster.rke.id
  name = format("%s-%s",var.node_pool_name,"etcd")
  hostname_prefix = var.hostname_prefix
  node_template_id = data.rancher2_node_template.controlplane_template.id

  quantity = var.etcd_node_count
  control_plane = false
  etcd = true
  worker = false
}

resource "rancher2_node_pool" "controlplane_pool" {
  cluster_id = rancher2_cluster.rke.id
  name = format("%s-%s",var.node_pool_name,"controlplane")
  hostname_prefix = var.hostname_prefix
  node_template_id = data.rancher2_node_template.controlplane_template.id

  quantity = var.controlplane_node_count
  control_plane = true
  etcd = false
  worker = false
}

resource "rancher2_node_pool" "workers_pool" {
  cluster_id = rancher2_cluster.rke.id
  name = format("%s-%s",var.node_pool_name,"workers")
  hostname_prefix = var.hostname_prefix
  node_template_id = data.rancher2_node_template.workers_template.id

  quantity = var.workers_node_count
  control_plane = false
  etcd = false
  worker = true
}