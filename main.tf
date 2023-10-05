module "vpc" {
  source = "git::https://github.com/kvmallika/tf-module-vpc.git"

  for_each = var.vpc
  cidr_block = each.value["cidr_block"]
  subnets = each.value["subnets"]
  tags = local.tags
  env = var.env
  default_vpc_id = var.default_vpc_id
  default_vpc_cidr = var.default_vpc_cidr
  default_vpc_rtid = var.default_vpc_rtid
}

module "docdb" {
  source = "git::https://github.com/kvmallika/tf-module-docdb.git"
  for_each = var.docdb
  kms_arn = var.kms_arn
  env = var.env
  tags = local.tags
  vpc_id = local.vpc_id
  subnets = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["subnet_name"],null),"subnet_ids",null)
  engine_version = each.value["engine_version"]
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["allow_db_cidr"],null),"subnet_cidrs",null)
}



/*
module "app" {
  source = "git::https://github.com/kvmallika/tf-module-app.git"

  for_each = var.app
  instance_type = each.value["instance_type"]
  desired_capacity = each.value["desired_capacity"]
  max_size = each.value["max_size"]
  min_size = each.value["min_size"]
  name = each.value["name"]

  env=var.env
  bastion_cidr_block = var.bastion_cidr_block
  tags = local.tags

  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["subnet_name"],null),"subnet_ids",null)
  vpc_id = lookup(lookup(module.vpc, "main" ,null ), "vpc_id" , null)
  allow_app_cidr = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["allow_app_cidr"],null),"subnet_cidrs",null)
}
*/



