output "efs_address" {
  description = "Address at which the file system may be mounted via the mount target."
  value       = data.aws_efs_mount_target.xwiki.ip_address
}