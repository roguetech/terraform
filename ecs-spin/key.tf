resource "aws_key_pair" "spin-key" {
  key_name   = "spin-key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
  lifecycle {
    ignore_changes = [public_key]
  }
}
