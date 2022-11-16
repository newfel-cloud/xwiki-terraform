output "db_hostname" {
  description = "The hostname of the RDS instance."
  value       = aws_db_instance.rds.address
}