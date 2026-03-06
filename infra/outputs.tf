output "alb_dns_name" {
  value = module.alb.dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
