##################################### DOCUMENTDB #####################################

#================ Parameter Group =================#
resource "aws_docdb_cluster_parameter_group" "db" {
  name   = "${var.project.env}-${var.project.name}-docdb"
  family = "docdb5.0"

  parameter {
    name  = "tls"
    value = "disabled"
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-docdb"
    Module = "${path.module}"
  })
}

#================ Subnet Group =================#
resource "aws_docdb_subnet_group" "db" {
  name       = "${var.project.env}-${var.project.name}-docdb"
  subnet_ids = var.docdb_subnet_ids

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-docdb"
    Module = "${path.module}"
  })
}

#================ DocumentDB Cluster =================#
resource "aws_docdb_cluster" "db" {
  cluster_identifier              = "${var.project.env}-${var.project.name}"
  engine                          = "docdb"
  engine_version                  = "5.0.0"
  master_username                 = "easyshop"
  master_password                 = random_password.docdb.result
  port                            = 27017
  db_subnet_group_name            = aws_docdb_subnet_group.db.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.db.name
  vpc_security_group_ids          = [aws_security_group.sg_db.id]
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_id
  backup_retention_period         = 7
  preferred_backup_window         = "02:00-03:00"
  preferred_maintenance_window    = "sun:04:00-sun:05:00"
  skip_final_snapshot             = true
  apply_immediately               = true
  deletion_protection             = false

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-docdb"
    Module = "${path.module}"
  })
}

#================ Primary Instance =================#
resource "aws_docdb_cluster_instance" "db" {
  identifier         = "${var.project.env}-${var.project.name}"
  cluster_identifier = aws_docdb_cluster.db.id
  instance_class     = "db.t3.medium"
  engine             = aws_docdb_cluster.db.engine
  apply_immediately  = true

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-docdb"
    Module = "${path.module}"
  })
}

#================ Random Password =================#
resource "random_password" "docdb" {
  length           = 16
  special          = true
  override_special = "_-"
}
