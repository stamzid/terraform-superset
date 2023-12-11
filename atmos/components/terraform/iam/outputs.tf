output "athena_user_access_key_id" {
  value = aws_iam_access_key.athena_user_key.id
}

output "eks_role_arn" {
  value = aws_iam_role.eks_role.arn
}
