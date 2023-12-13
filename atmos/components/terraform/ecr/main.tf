locals {
  lifecycle_policy = {
    rules = [
      {
        rulePriority = 1
        description  = "Expire images older than 30 days"
        selection    = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
}

resource "aws_ecr_repository" "this" {
  count = length(var.services)
  name  = var.services[count.index]

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = { for repo in aws_ecr_repository.this : repo.name => repo.name }

  repository = each.value
  policy     = jsonencode(local.lifecycle_policy)
}

output "repository_url" {
  value = aws_ecr_repository.this[*].repository_url
}
