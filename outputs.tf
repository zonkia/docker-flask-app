output "app_address" {
  value       = "http://${aws_instance.terra-app-instance.public_ip}:${var.app_port}"
  description = "App address"
}
output "ecr_registry" {
  value       = var.ecr_registry
  description = "App address"
}
output "image_name" {
  value       = var.image_name
  description = "App address"
}