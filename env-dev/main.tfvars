 env = "dev"
 monitor_cidr = ["172.31.85.231/32"]
 bastion_cidr_block = ["172.31.89.197/32"]
 default_vpc_id = "vpc-0adba6e2400ad6ae9"
 default_vpc_cidr = "172.31.0.0/16"
 default_vpc_rtid = "rtb-02de44b9fcc4a8e9d"
 kms_arn = "arn:aws:kms:us-east-1:689505382884:key/8ad7b83e-d322-4cb4-a3cf-f1210e2a762a"
 domain_name = "vemudevops.online"
 domain_id = "Z025574148TA976KXQTI"

 vpc = {
   main = {
     cidr_block = "10.0.0.0/16"
     subnets = {
       public = {
         name = "public"
         cidr_block = ["10.0.0.0/24","10.0.1.0/24"]
         azs = ["us-east-1a","us-east-1b"]
       }
       web = {
         name = "web"
         cidr_block = ["10.0.2.0/24","10.0.3.0/24"]
         azs = ["us-east-1a","us-east-1b"]
       }
       app = {
         name = "app"
         cidr_block = ["10.0.4.0/24","10.0.5.0/24"]
         azs = ["us-east-1a","us-east-1b"]
       }
       db = {
         name = "db"
         cidr_block = ["10.0.6.0/24","10.0.7.0/24"]
         azs = ["us-east-1a","us-east-1b"]
       }
     }
  }
}
 docdb = {
   main = {
     subnet_name    = "db"
     allow_db_cidr  = "app"
     engine_version = "4.0.0"
     instance_count = 1
     instance_class = "db.t3.medium"
   }
 }
 rds = {
   main = {
     subnet_name    = "db"
     allow_db_cidr  = "app"
     engine_version = "5.7.mysql_aurora.2.11.2"
     instance_count = 1
     instance_class = "db.t3.small"
   }
 }
 elasticache = {
   main = {
     subnet_name             = "db"
     allow_db_cidr           = "app"
     engine_version          = "6.x"
     num_node_groups         = 1
     node_type               = "cache.t3.micro"
     replicas_per_node_group = 1
   }
 }
 rabbitmq = {
   main = {
     subnet_name   = "db"
     allow_db_cidr = "app"
     instance_type = "t3.small"
   }
 }
 app  = {
   frontend = {
     name               = "frontend"
     instance_type      = "t3.small"
     subnet_name        = "web"
     allow_app_cidr     = "public"
     desired_capacity   = 1
     max_size           = 10
     min_size           = 1
     app_port           = 80
     listener_priority  = 1
     lb_type            = "public"
     dns_name           = "dev"
     parameters         = []
   }
   catalogue = {
     name               = "catalogue"
     instance_type      = "t3.small"
     subnet_name        = "app"
     allow_app_cidr     = "app"
     desired_capacity   = 1
     max_size           = 10
     min_size           = 1
     app_port           = 8080
     listener_priority  = 1
     lb_type            = "private"
     parameters         = ["docdb"]
  }
   user = {
     name               = "user"
     instance_type      = "t3.small"
     subnet_name        = "app"
     allow_app_cidr     = "app"
     desired_capacity   = 1
     max_size           = 10
     min_size           = 1
     app_port           = 8080
     listener_priority  = 2
     lb_type            = "private"
     parameters         = ["docdb"]
   }
   cart = {
     name               = "cart"
     instance_type      = "t3.small"
     subnet_name        = "app"
     allow_app_cidr     = "app"
     desired_capacity   = 1
     max_size           = 10
     min_size           = 1
     app_port           = 8080
     listener_priority  = 3
     lb_type            = "private"
     parameters         = []
   }
   shipping = {
     name               = "shipping"
     instance_type      = "t3.small"
     subnet_name        = "app"
     allow_app_cidr     = "app"
     desired_capacity   = 1
     max_size           = 10
     min_size           = 1
     app_port           = 8080
     listener_priority  = 4
     lb_type            = "private"
     parameters         = ["rds"]
   }
   payment = {
     name               = "payment"
     instance_type      = "t3.small"
     subnet_name        = "app"
     allow_app_cidr     = "app"
     desired_capacity   = 1
     max_size           = 10
     min_size           = 1
     app_port           = 8080
     listener_priority  = 5
     lb_type            = "private"
     parameters         = []
   }
 }

 alb = {
   public={
     name           = "public"
     subnet_name    ="public"
     internal       = false
     allow_alb_cidr = null

   }
   private={
     name           = "private"
     subnet_name    ="app"
     internal       = true
     allow_alb_cidr = "web"

   }
 }