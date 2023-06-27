locals {
  name = var.env != "" ? "${var.componet_name}-${var.env}" : var.component_name
}