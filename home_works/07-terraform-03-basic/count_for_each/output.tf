#output "internal_ip_address_vm_01" {
#  value = yandex_compute_instance.vm-01.*.network_interface.0.ip_address
#}
#
#output "external_ip_address_vm_01" {
#  value = yandex_compute_instance.vm-01.*.network_interface.0.nat_ip_address
#}


#output "internal_ip_address_count" {
#  value = yandex_compute_instance.vm_count.*.network_interface.0.ip_address
#}
#
#output "external_ip_address_count" {
#  value = yandex_compute_instance.vm_count.*.network_interface.0.nat_ip_address
#}
