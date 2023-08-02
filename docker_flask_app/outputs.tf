output "app_address" {
  value       = "http://${aws_instance.mstan-terra-app-instance.public_ip}:${var.app_port}"
  description = "App address"
}