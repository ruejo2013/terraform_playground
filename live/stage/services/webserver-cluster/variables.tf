# server port var
variable "server_port" {
  type        = number
  default     = 8080
  description = "store the http server port address"
}

# port var
variable "port_num" {
  type        = number
  default     = 80
  description = "http server port number"
}

variable "cluster_name" {
    description   = "The cluster name"
    type          = string
    default       = "webserver-dev"
}

variable "aws_ami" {
    description   = "The cluster name"
    type          = string
    default       = "ami-053b0d53c279acc90"
}

variable "server_text" {
    description   = "The cluster name"
    type          = string
    default       = "New Dev server"
}

variable "bucket_name" {
    description = "S3 bucket name"
    type        = string
    default     = "mena-terraform-up-and-running-bucket"
}

variable "env" {
    description = "env"
    type        = string
    default     = "dev"
}

variable "db_engine" {
    description = "Database type"
    type        = string
    default     = "mysql"
}