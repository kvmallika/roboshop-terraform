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

  kms_arn   = var.kms_arn
  env       = var.env
  tags      = local.tags
  vpc_id    = local.vpc_id

  subnets = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["subnet_name"],null),"subnet_ids",null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["allow_db_cidr"],null),"subnet_cidrs",null)

  engine_version = each.value["engine_version"]
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]

}


module "rds" {
  source = "git::https://github.com/kvmallika/tf-module-rds.git"
  for_each = var.rds

  kms_arn  = var.kms_arn
  env      = var.env
  tags     = local.tags
  vpc_id   = local.vpc_id

  subnets = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["subnet_name"],null),"subnet_ids",null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["allow_db_cidr"],null),"subnet_cidrs",null)

  engine_version = each.value["engine_version"]
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]

}

module "elasticache" {
  source = "git::https://github.com/kvmallika/tf-module-elasticache.git"
  for_each    = var.elasticache

  kms_arn     = var.kms_arn
  env         = var.env
  tags        = local.tags
  vpc_id      = local.vpc_id

  subnets = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["subnet_name"],null),"subnet_ids",null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["allow_db_cidr"],null),"subnet_cidrs",null)

  engine_version          = each.value["engine_version"]
  num_node_groups         = each.value["num_node_groups"]
  node_type               = each.value["node_type"]
  replicas_per_node_group = each.value["replicas_per_node_group"]

}
module "rabbitmq" {
  source = "git::https://github.com/kvmallika/tf-module-amazon-mq.git"
  for_each           = var.rabbitmq

  kms_arn            = var.kms_arn
  env                = var.env
  tags               = local.tags
  vpc_id             = local.vpc_id
  bastion_cidr_block = var.bastion_cidr_block

  subnets = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["subnet_name"],null),"subnet_ids",null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["allow_db_cidr"],null),"subnet_cidrs",null)

  instance_type = each.value["instance_type"]

}

module "alb" {
  source = "git::https://github.com/kvmallika/tf-module-alb.git"
  for_each = var.alb


  env                = var.env
  tags               = local.tags
  vpc_id             = local.vpc_id

  subnets = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["subnet_name"],null),"subnet_ids",null)
  allow_alb_cidr = each.value["name"] == "public" ? ["0.0.0.0/0"] : lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["allow_alb_cidr"],null),"subnet_cidrs",null)

  name     = each.value["name"]
  internal = each.value["internal"]
}

module "app" {
  depends_on =[module.vpc, module.docdb, module.elasticache, module.rabbitmq, module.rds, module.alb]
  source = "git::https://github.com/kvmallika/tf-module-app.git"

  for_each           = var.app
  env                = var.env
  bastion_cidr_block = var.bastion_cidr_block
  tags               = local.tags
  domain_name        = var.domain_name
  domain_id          = var.domain_id
  kms_arn            = var.kms_arn
  dns_name           = each.value["name"] == "frontend" ? each.value["dns_name"] : "${each.value["name"]}-${var.env}"

  instance_type    = each.value["instance_type"]
  desired_capacity = each.value["desired_capacity"]
  max_size         = each.value["max_size"]
  min_size         = each.value["min_size"]
  name             = each.value["name"]
  app_port         = each.value["app_port"]
  listener_priority= each.value["listener_priority"]

  subnets = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["subnet_name"],null),"subnet_ids",null)
  vpc_id = lookup(lookup(module.vpc, "main" ,null ), "vpc_id" , null)
  listener_arn = lookup(lookup(module.alb, each.value["lb_type"] ,null ), "listener_arn" , null)
  lb_dns_name  = lookup(lookup(module.alb, each.value["lb_type"] ,null ), "dns_name" , null)
  allow_app_cidr = lookup(lookup(lookup(lookup(module.vpc, "main" ,null ), "subnets" , null), each.value["allow_app_cidr"],null),"subnet_cidrs",null)
}




