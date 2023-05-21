output "iam_users" {
  value       = module.iam_users[*].iam_user_arn
  description = "The ARNs of the created IAM Users"
}

