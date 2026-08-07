variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "region" {
  type        = string
  description = "The GCP region for the cluster"
}

variable "gke_node_roles" {
  type        = set(string)
  description = "List of IAM roles required by the GKE nodes"
}

variable "node_pools" {
  type = map(object({
    node_count   = number
    machine_type = string
    preemptible  = bool
  }))
  description = "Map of node pool configurations"
}
