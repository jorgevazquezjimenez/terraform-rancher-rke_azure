output "cluster_id" {
  value = module.rke_cluster.cluster_id
}

output "kube_config" {
  value = module.rke_cluster.kube_config
  sensitive = true
}

output "node_pool_id" {
  value = module.node_pool.node_pool_id
}