resource "aws_elasticache_cluster" "default" {
  cluster_id           = "${var.prefix}-explorer-redis"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  port                 = 6379
  security_group_ids   = ["${aws_security_group.redis.id}"]
  availability_zone    = "${data.aws_availability_zones.available.names[0]}"
  subnet_group_name    = "${aws_elasticache_subnet_group.redis.id}"

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.prefix}-redis-subnet-group"
  subnet_ids = ["${aws_subnet.redis.id}"]
}
