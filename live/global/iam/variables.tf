variable "iam_user_names" {
    description = "Create IAM users from the list of names below"
    type        = list(string)
    default     = ["Patk", "Tivity", "Morpheous"]
}