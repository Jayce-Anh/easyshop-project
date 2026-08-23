################################ OUTPUTS ################################

output "docdb_endpoint" {
  description = "Cluster writer hostname"
  value       = aws_docdb_cluster.db.endpoint
}

output "docdb_address" {
  description = "Cluster writer hostname"
  value       = aws_docdb_cluster.db.endpoint
}

output "docdb_reader_endpoint" {
  description = "Cluster reader endpoint"
  value       = aws_docdb_cluster.db.reader_endpoint
}

output "docdb_port" {
  description = "DocumentDB port"
  value       = aws_docdb_cluster.db.port
}

output "docdb_arn" {
  description = "ARN of the DocumentDB cluster"
  value       = aws_docdb_cluster.db.arn
}

output "docdb_credentials" {
  sensitive = true
  value = {
    DATABASE_USERNAME = "${aws_docdb_cluster.db.master_username}"
    DATABASE_PASSWORD = "${random_password.docdb.result}"
    DATABASE_HOST     = "${aws_docdb_cluster.db.endpoint}"
    DATABASE_PORT     = "${aws_docdb_cluster.db.port}"
  }
  description = "DocumentDB credentials for Secret Manager"
}
