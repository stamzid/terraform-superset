variable "namespace" {
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
  type        = string
}

variable "environment" {
  description = "Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'"
  type        = string
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
  type        = string
}

variable "name" {
  description = "Solution name, e.g. 'app' or 'jenkins'"
  type        = string
  default     = "ecr"
}

variable "attributes" {
  description = "Additional attributes (e.g. `policy` or `role`)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags (e.g. map('BusinessUnit','XYZ'))"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "profile" {
  description = "AWS profile name"
  type        = string
  default     = "default"
}

variable "label_order" {
  description = "The naming order of the id output and Name tag"
  type        = list(string)
  default     = ["namespace", "environment", "stage", "name", "attributes"]
}

variable "services" {
  description = "List of services for which to create ECR repositories"
  type        = list(string)
  default     = ["service1", "service2", "service3", "service4", "service5", "service6", "service7"]
}

variable "delimiter" {
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`"
  type        = string
  default     = "-"
}

variable "tenant" {
  description = "Tenant of this resource instance"
  type        = string
}
