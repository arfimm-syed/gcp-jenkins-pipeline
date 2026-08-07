module "my_bucket" {
  source     = "../modules"
  project_id = var.project_id
  my_bucket  = var.my_bucket
}

# --- Keep your existing module "my_bucket" configuration here ---

module "gke_playground" {
  source = "../modules/gke" # Points relatively to your modules folder

  project_id     = var.project_id
  region         = var.region
  gke_node_roles = var.gke_node_roles
  node_pools     = var.node_pools
}
