# Genera el inventario de Ansible (fichero "hosts") a partir de las IP del escenario
resource "local_file" "inventario" {
  filename        = "${path.module}/hosts"
  file_permission = "0644"
  content = templatefile("${path.module}/inventario.tftpl", {
    ip_server1 = try(libvirt_domain.ej5-server1.network_interface[0].addresses[0], "")
    ip_server2 = "10.0.0.2" # estática: está en cloud-init/network-config2.yaml
  })
}
