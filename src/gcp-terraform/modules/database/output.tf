output "db_ip" {
  description = "The IPv4 address assigned for the master instance"
  value       = google_sql_database_instance.xwiki_inatance.private_ip_address
}