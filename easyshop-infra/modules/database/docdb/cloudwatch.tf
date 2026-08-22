############################# DOCDB CLOUDWATCH #####################################

#================== CloudWatch Dashboard (DocDB IO) ==================#
resource "aws_cloudwatch_dashboard" "docdb" {
  dashboard_name = "${var.project.env}-${var.project.name}-docdb-observability"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "DocDB CPU Utilization (%)"
          region = var.project.region
          view   = "timeSeries"
          metrics = [
            ["AWS/DocDB", "CPUUtilization", "DBClusterIdentifier", aws_docdb_cluster.db.cluster_identifier],
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "DocDB Read/Write IOPS"
          region = var.project.region
          view   = "timeSeries"
          metrics = [
            ["AWS/DocDB", "ReadIOPS", "DBClusterIdentifier", aws_docdb_cluster.db.cluster_identifier, { label = "ReadIOPS" }],
            ["AWS/DocDB", "WriteIOPS", "DBClusterIdentifier", aws_docdb_cluster.db.cluster_identifier, { label = "WriteIOPS" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "DocDB Latency (ms) / Connections"
          region = var.project.region
          view   = "timeSeries"
          metrics = [
            ["AWS/DocDB", "ReadLatency", "DBClusterIdentifier", aws_docdb_cluster.db.cluster_identifier, { label = "ReadLatency" }],
            ["AWS/DocDB", "WriteLatency", "DBClusterIdentifier", aws_docdb_cluster.db.cluster_identifier, { label = "WriteLatency" }],
            ["AWS/DocDB", "DatabaseConnections", "DBClusterIdentifier", aws_docdb_cluster.db.cluster_identifier, { label = "Connections", yAxis = "right" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "DocDB Volume Bytes Used"
          region = var.project.region
          view   = "timeSeries"
          metrics = [
            ["AWS/DocDB", "VolumeBytesUsed", "DBClusterIdentifier", aws_docdb_cluster.db.cluster_identifier],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "DocDB Throughput (Bytes/sec)"
          region = var.project.region
          view   = "timeSeries"
          metrics = [
            ["AWS/DocDB", "NetworkThroughput", "DBClusterIdentifier", aws_docdb_cluster.db.cluster_identifier],
          ]
        }
      },
    ]
  })
}
