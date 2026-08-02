project_id = "gcp-jenkins-pipeline"
my_bucket = {
    bucket1 = {
      name     = "my-unique-bucket-name"
      location = "US"
      force_destroy = true

  versioning = {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }
    }
}