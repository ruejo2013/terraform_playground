variable "cluster_name" {
    description   = "The cluster name"
    type          = string
    default       = "webserver-prod"
}

variable "bucket_name" {
    description = "S3 bucket name"
    type        = string
    default     = "mena-terraform-up-and-running-bucket"
}

variable "env" {
    description = "env"
    type        = string
    default     = "prod"
}

variable "db_engine" {
    description = "Database type"
    type        = string
    default     = "postgres"
}