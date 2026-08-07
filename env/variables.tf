variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "my_bucket" {
  description = "The name of the storage bucket."
  type = map(object({
    name                        = string
    location                    = string
    uniform_bucket_level_access = bool
  }))
}


variable "region" { type = string }
variable "gke_node_roles" { type = set(string) }
variable "node_pools" {
  type = map(object({
    node_count   = number
    machine_type = string
    preemptible  = bool
  }))
}
