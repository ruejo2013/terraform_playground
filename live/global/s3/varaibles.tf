variable "bucket_name" {
    description = "S3 bucket name"
    type        = string
    default     = "mena-terraform-up-and-running-bucket"
}

variable "sse_algo" {
    description = "SSE algorithm"
    type        = string
    default     = "AES256"
}

variable "dynamodb_lock" {
    description = "Dynamo db state file lock tab"
    type        = string
    default     = "terraform_dynamo_tf_stfile_lock"
}