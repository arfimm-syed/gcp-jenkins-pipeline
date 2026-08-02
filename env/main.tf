module "my_bucket" {
  source     = "../modules"
  project_id = var.project_id
  my_bucket  = var.my_bucket
}