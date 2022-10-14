module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.1.0"

  // Engine options
  engine               = "mysql"
  engine_version       = "8.0.28"
  family               = "mysql8.0" # require
  major_engine_version = "8.0"      # require
  // Settings
  identifier = "xwiki-s-db"
  username   = "root"
  password   = "1qaz2wsx" // least 8 char
  // Instance configuration
  instance_class = "db.t3.medium"
  // Storage
  storage_type      = "standard" //magnetic
  allocated_storage = 20
  // Connectivity
  vpc_security_group_ids = [
    var.sg_map.common.security_group_id,
  ]
  // Additional configuration
  db_name = "xwiki"


  skip_final_snapshot = true
}