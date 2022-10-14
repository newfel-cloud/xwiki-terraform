data "aws_availability_zones" "default" {

}

resource "aws_efs_file_system" "xwiki" {
  // no name argument
  availability_zone_name = data.aws_availability_zones.default.names[0]
  encrypted              = true
}

resource "aws_efs_mount_target" "xwiki" {
  file_system_id = aws_efs_file_system.xwiki.id
  subnet_id      = var.subnets[0].id
  security_groups = [
    var.sg_map.common.security_group_id,
  ]
}

resource "aws_efs_access_point" "xwiki" {
  // no name argument
  file_system_id = aws_efs_file_system.xwiki.id
  tags = {
    "Name" = "xwiki_file_share"
  }
}