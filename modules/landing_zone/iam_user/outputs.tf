
output "iam_user_arn" {
    value       = aws_iam_user.iam_user.arn
    description = "The arn of the IAM user"
}