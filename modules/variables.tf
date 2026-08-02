variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}
 
variable "my_bucket"{
  description = "The name of the storage bucket."
  type        = map(object({
    name     = string
    location = string
    force_destroy = bool
  }))
}

