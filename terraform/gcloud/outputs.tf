output "controller_accounts" {
  value = module.compute.controller_accounts[*]
}

output "external_ip" {
  value = module.compute.external_ip
}

output "worker_ips" {
  value = module.compute.worker_ips
}
