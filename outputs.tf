
output "server1-ip" {
  value = module.server1.public_ip_address
}

output "server2-ip" {
  value = module.server2.public_ip_address
}
