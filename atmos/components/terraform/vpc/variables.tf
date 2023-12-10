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

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets_enabled" {
  description = "Public subnet enablement"
  type        = bool
  default     = true
}

variable "subnets_cidr_blocks" {
  description = "List of CIDR blocks for the private and public subnets"
  type = list(object({
    private  = list(string)
    public = list(string)
  }))
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "map_public_ip_on_launch" {
  description = "Specifies whether instances that are launched in this subnet should be assigned a public IP address"
  type        = bool
  default     = false
}

variable "max_subnet_count" {
  description = "The maximum amount of subnets to deploy.  This constrains the number of AZs that can be deployed."
  type        = number
  default     = 4
}

variable "nat_gateway_enabled" {
  description = "Flag to enable/disable NAT gateways"
  type        = bool
  default     = true
}

variable "subnet_type_tag_key" {
  description = "The key for a tag to assign to the subnet indicating the type of the subnet (i.e. 'Public', 'Private', 'Database')"
  type        = string
  default     = "cpco.io/subnet/type"
}

variable "subnet_type_tag_value_format" {
  description = "The format of the value for the subnet type tag"
  type        = string
  default     = "%s subnet"
}

variable "nat_instance_enabled" {
  description = "NAT instances for private internet access"
  type        = bool
  default     = true
}

variable "nat_instance_type" {
  description = "NAT instances type private internet access"
  type        = string
  default     = "t4g.micro"
}
