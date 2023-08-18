output "app_address" {
  value       = "http://${aws_instance.terra-app-instance.public_ip}:${var.app_port}"
  description = "App address"
}
output "image_name" {
  value       = "http://${aws_eip.eip.public_ip}:${var.app_port}"
  description = "App address"
}