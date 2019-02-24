resource "aws_key_pair" "blockscout" {
  count      = "${var.key_content == "" ? 0 : 1}"
  key_name   = "${var.key_name}"
  public_key = "${var.key_content}"
}
