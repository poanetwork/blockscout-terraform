# Internal DNS Zone
resource "aws_route53_zone" "main" {
  name   = "${var.prefix}.${var.dns_zone_name}"
  vpc {
    vpc_id = aws_vpc.vpc.id
  }

  tags = {
    prefix = var.prefix
    origin = "terraform"
  }
}

# Private DNS records
resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "db${count.index}"
  type    = "CNAME"
  ttl     = 300
  count   = length(var.chains)
  records = [aws_rds_cluster.postgresql[count.index].endpoint]
}

resource "aws_route53_record" "db_reader" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "dbread${count.index}"
  type    = "CNAME"
  ttl     = 300
  count   = length(var.chains)
  records = [aws_rds_cluster.postgresql[count.index].endpoint]
}
