project_id = "gcp-jenkins-pipeline"
my_bucket = {
  bucket1 = {
    name                        = "arfimm-bucket"
    location                    = "US"
    uniform_bucket_level_access = true
  }
}


region = "us-central1-a"

gke_node_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter"
]

node_pools = {
  "playground-pool" = {
    node_count   = 1
    machine_type = "e2-standard-2"
    preemptible  = true
  }
}
