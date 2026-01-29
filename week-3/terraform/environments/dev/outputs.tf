output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "redis_endpoint" {
  value = module.elasticache.redis_endpoint
}

output "sqs_queue_url" {
  value = module.sqs.sqs_queue_id
}
