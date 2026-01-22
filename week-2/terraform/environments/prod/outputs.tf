output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "database_private_ip" {
  value = module.database.db_private_ip
}
