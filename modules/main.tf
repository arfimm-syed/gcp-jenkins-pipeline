resource "google_storage_bucket" "my_bucket" {
  name     = "arfimm-bucket"
  location = "US"
  uniform_bucket_level_access = true
}