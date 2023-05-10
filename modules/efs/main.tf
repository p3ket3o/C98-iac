resource "aws_efs_file_system" "this" {
tags = {
    Name = "production"
  }
}

resource "aws_efs_mount_target" "this" {
  count = 3
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet[count.index]
  security_groups = var.security_group
}