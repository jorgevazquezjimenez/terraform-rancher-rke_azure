output "cluster_id" {
  value = rancher2_cluster.rke.id
}

output "kubernetes_config" {
  value = rancher2_cluster.rke.kubernetes_config
  sensitive = true
}