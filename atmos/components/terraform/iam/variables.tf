variable "region" {
  description = "Infrastructure Region"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "Infrastructure Profile"
  type        = string
}

variable "namespace" {
  description = "Superset Environment Namespace"
  type        = string
}

variable "environment" {
  description = "Deployment Environment Identifier Prefix"
  type        = string
}

variable "stage" {
  description = "Deployment stage"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Resource name"
  type        = string
  default     = "s3"
}

variable "tenant" {
  description = "Name of the tenant environment is being set up for"
  type        = string
}

variable "attributes" {
  description = "Additional attributes (e.g. `1`)"
  type        = list(string)
  default     = []
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

variable "regex_replace_chars" {
  description = "Regex to replace chars with empty string in `namespace`, `environment`, `stage`, `name` and `attributes`"
  type        = string
  default     = "/[^a-zA-Z0-9-]/"
}
