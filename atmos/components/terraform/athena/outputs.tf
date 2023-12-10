output "athena_database_name" {
  value = aws_athena_database.superset_database.name
  description = "The name of the Athena database"
}

output "athena_workgroup_arn" {
  value = aws_athena_workgroup.superset_workgroup.arn
  description = "The ARN of the Athena workgroup"
}

output "athena_workgroup_name" {
  value = aws_athena_workgroup.superset_workgroup.name
  description = "The name of the Athena workgroup"
}
