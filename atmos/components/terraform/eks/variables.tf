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

variable "cluster_version" {
  description = "Kube cluster version"
  type        = string
}

variable "node_group_ami_type" {
  description = "Node group ami type"
  type        = string
  default     = "AL2_x86_64"
}

variable "instance_types" {
  description = "Cluster instance types"
  type        = list(string)
}

variable "max_size" {
  description = "Cluster max size"
  type        = number
}

variable "min_size" {
  description = "Cluster min size"
  type        = number
}

variable "desired_size" {
  description = "Cluster desired size"
  type        = number
}

variable "addon_ebs_csi_version" {
  description = "EBS csi driver version"
  type        = string
  default     = "v1.20.0-eksbuild.1"
}
