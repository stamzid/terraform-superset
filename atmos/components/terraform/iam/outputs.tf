output "athena_user_access_key_id" {
  value = aws_iam_access_key.athena_user_key.id
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "athena_role_arn" {
  value = aws_iam_role.athena_role.arn
}
