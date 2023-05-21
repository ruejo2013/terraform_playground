
variable "db_username" {
    description   = "The username for the database"
    type          = string
    sensitive     = true
}


variable "db_password" {
    description   = "The password for the database"
    type          = string
    sensitive     = true
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

variable "dynamodb_lock" {
    description = "Dynamo db state file lock tab"
    type        = string
    default     = "terraform_dynamo_tf_stfile_lock"
}

variable "db_engine" {
    description = "Database type"
    type        = string
    default     = "postgres"
}

variable "db_name" {
    description = "Database type"
    type        = string
    default     = "terraform_prod_db"
}