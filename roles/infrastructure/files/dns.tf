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
  type    = "A"
  count   = length(var.chains)

  alias {
    name                   = aws_rds_cluster.postgresql[count.index].endpoint
    zone_id                = aws_rds_cluster.postgresql[count.index].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "db_reader" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "dbread${count.index}"
  type    = "A"
  count   = length(var.chains)

  alias {
    name                   = aws_rds_cluster.postgresql[count.index].reader_endpoint
    zone_id                = aws_rds_cluster.postgresql[count.index].hosted_zone_id
    evaluate_target_health = false
  }
}
