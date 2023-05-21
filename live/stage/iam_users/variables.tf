
variable "user_names" {
    description = "Create IAM users from the list of names below"
    type        = list(string)
    default     = ["Pat1", "Tivity", "Morpheous1"]
}