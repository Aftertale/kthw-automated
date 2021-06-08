output "controller_accounts" {
  value = google_service_account.controller[*]
}

output "worker_ips" {
  value = zipmap(concat(var.workers, var.controllers), concat(
  tolist([
    for vm in google_compute_instance.workers : vm.network_interface.0.network_ip
  ]), 
  tolist([
    for vm in google_compute_instance.controllers : vm.network_interface.0.network_ip
  ])))
}

output "external_ip" {
  value = google_compute_address.external
}
