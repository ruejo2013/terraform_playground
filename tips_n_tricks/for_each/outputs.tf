output "iam_users" {
  value       = values(aws_iam_user.iam_foreach)[*].arn
  description = "The ARNs of the created IAM Users"
}

# using for expression
# output the IAM user names in upper case
output "upper_usernames" {
  value       = [for name in var.names : upper(name)]
  description = "The ARNs of the created IAM Users"
}