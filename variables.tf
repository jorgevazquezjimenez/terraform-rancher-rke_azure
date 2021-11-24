variable "api_url" {
  type = string
  description = "(Required) Rancher API URL"
}

variable "access_key" {
  type = string
  description = "(Required) Rancher Access Key"
}

variable "secret_key" {
  type = string
  description = "(Required) Rancher Secret Key"
}

# RKE config
variable "name" {
  type = string
  description = "(Required) Rancher RKE cluster name"
}

variable "description" {
  type = string
  description = "(Required) RKE cluster description"
}

variable "node_template_name" {
  type = string
  description = "(Required) RKE worker nodes template name."
}

variable "node_pool_name" {
  type = string
  description = "(Required) RKE node pool name."
  default = "agentpool"
}

variable "kubernetes_network_plugin" {
  type = string
  description = "(Optional) Kubernetes network plugin. Default value is calico"
  default = "calico"
}

variable "hostname_prefix" {
  type = string
  description = "(Optional) Hostname prefix for nodes. Default value is rancher"
  default = "rancher"
}

variable "quantity" {
  type = number
  description = "(Optional) Number of nodes to create. Default value is 1"
  default = 3
}