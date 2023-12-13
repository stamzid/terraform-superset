variable "profile" {
  type        = string
  description = "AWS Profile"
}

variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name or abbreviation"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "environment" {
  type        = string
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'UAT'"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', 'UAT'"
}

variable "tenant" {
  type        = string
  description = "Tenant"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'jenkins'"
  default     = "network"
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
  type        = map(string)
  default     = {}
}

variable "delimiter" {
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`"
  type        = string
  default     = "-"
}

variable "label_order" {
  description = "The naming order of the id output and Name tag"
  type        = list(string)
  default     = ["namespace", "environment", "stage", "name", "attributes"]
}

variable "attributes" {
  description = "Additional attributes (e.g. `1`)"
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone id"
  type        = string
}
