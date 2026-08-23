############################# ELASTICACHE OUTPUT #################################
output "cache_replication_group_id" {
  value = aws_elasticache_replication_group.cache.id
}

output "cache_primary_endpoint" {
  value = aws_elasticache_replication_group.cache.primary_endpoint_address
}

output "cache_reader_endpoint" {
  value = aws_elasticache_replication_group.cache.reader_endpoint_address
}

output "cache_port" {
  value = aws_elasticache_replication_group.cache.port
}

output "cache_credentials" {
  sensitive = true
  value = {
    CACHE_HOST = "${aws_elasticache_replication_group.cache.primary_endpoint_address}"
    CACHE_PORT = "${aws_elasticache_replication_group.cache.port}"
  }
  description = "Cache credentials for Secret Manager"
}
