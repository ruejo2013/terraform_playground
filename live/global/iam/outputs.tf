output "first_user_arn" {
    value       = aws_iam_user.iam-users[0].arn
    description = "The arn of the first IAM user"
}


output "all_users_arn" {
    value       = aws_iam_user.iam-users[*].arn
    description = "The arn of all IAM user"
}