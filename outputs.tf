output "instance_address" {
  value       = "http://${aws_instance.terra-app-instance.public_ip}:${var.app_port}"
  description = "App address"
}
output "app_address" {
  value       = "http://${aws_eip.eip.public_ip}:${var.app_port}"
  description = "App address"
}
output "eip_address" {
  value       = aws_eip.eip.public_ip
  description = "EIP address"
}
output "private_key" {
  value = local_file.terra-ssh-key
}