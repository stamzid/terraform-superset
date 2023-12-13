module "this" {
  source = "cloudposse/label/null"
  version     = "0.25.0"
  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  delimiter   = var.delimiter
  label_order = var.label_order
  tags        = var.tags
}
