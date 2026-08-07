# 1. Dev GKE Node Service Account
resource "google_service_account" "default" {
  account_id   = "dev-gke-node-sa"
  display_name = "Dev GKE Node Service Account"
}

# 2. Dynamic IAM Assignment
resource "google_project_iam_member" "node_permissions" {
  for_each = var.gke_node_roles

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.default.email}"
}

# 3. GKE Control Plane
resource "google_container_cluster" "primary" {
  name       = "my-gke-cluster"
  location   = var.region
  network    = "default"
  subnetwork = "default"

  remove_default_node_pool = true
  initial_node_count       = 1

  depends_on = [google_project_service.container_api]
}

# 4. Dynamic Node Pool Creation
resource "google_container_node_pool" "dynamic_nodes" {
  for_each = var.node_pools

  name       = each.key
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = each.value.node_count

  node_config {
    preemptible  = each.value.preemptible
    machine_type = each.value.machine_type

    service_account = google_service_account.default.email
    oauth_scopes    = ["https://googleapis.com"]
  }

  depends_on = [google_project_iam_member.node_permissions]
}

resource "google_project_service" "container_api" {
  project            = "gcp-jenkins-pipeline"
  service            = "container.googleapis.com"
  disable_on_destroy = false
}



