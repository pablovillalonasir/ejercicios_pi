# server1: ip1 por DHCP (NAT), ip2 estática en red muy aislada
output "ej5-server1" {
  value = {
    nombre = "ej5-server1"
    ip1    = try(libvirt_domain.ej5-server1.network_interface[0].addresses[0], "No disponible")
    ip2    = "10.0.0.1" # estática: está en cloud-init/network-config1.yaml
  }
}

# server2: solo red muy aislada con IP estática
output "ej5-server2" {
  value = {
    nombre = "ej5-server2"
    ip1    = "10.0.0.2" # estática: está en cloud-init/network-config2.yaml
  }
}
