resource "google_storage_bucket" "my_bucket" {
  name     = "my-unique-bucket-name"
  location = "US"
  uniform_bucket_level_access = true
}