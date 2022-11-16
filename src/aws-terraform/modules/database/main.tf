resource "aws_db_instance" "rds" {
  // Engine options
  engine         = "mysql"
  engine_version = "8.0.28"
  // Settings
  identifier = "xwiki-s-db"
  username   = "root"
  password   = "1qaz2wsx" // least 8 char
  // Instance configuration
  instance_class = "db.t3.medium"
  // Storage
  storage_type      = "standard" //magnetic
  allocated_storage = 20
  multi_az          = var.enable_high_availability
  // Connectivity
  vpc_security_group_ids = [
    var.sg_map["common"].security_group_id,
  ]
  // Additional configuration
  db_name = "xwiki"
  // Back up
  backup_retention_period = 7

  skip_final_snapshot = true
}