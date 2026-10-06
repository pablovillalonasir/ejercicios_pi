##############################################
# server1 — Debian (router/gateway)
##############################################

# Clon ligero sobre la imagen base Debian
resource "libvirt_volume" "ej5-server1-disk" {
  name             = "ej5-server1.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_debian
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

# ISO cloud-init con la configuración inicial de server1
resource "libvirt_cloudinit_disk" "ej5-server1-cloudinit" {
  name           = "ej5-server1-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = file("${path.module}/cloud-init/user-data1.yaml")
  network_config = file("${path.module}/cloud-init/network-config1.yaml")
}

resource "libvirt_domain" "ej5-server1" {
  name   = "ej5-server1"
  memory = 1024
  vcpu   = 2

  # Pide las IP al agente de QEMU (qemu-guest-agent): así se conocen también las estáticas
  qemu_agent = true

  # Red 1: NAT con DHCP (acceso exterior)
  network_interface {
    network_id     = libvirt_network.ej5-nat-dhcp.id
    wait_for_lease = true
  }

  # Red 2: muy aislada (IP estática 10.0.0.1, gateway hacia server2)
  network_interface {
    network_id = libvirt_network.ej5-muy-aislada.id
  }

  disk { volume_id = libvirt_volume.ej5-server1-disk.id }
  cloudinit = libvirt_cloudinit_disk.ej5-server1-cloudinit.id

  # Consola serie: las imágenes cloud la esperan (sin ella, algunas, como
  # Ubuntu, no terminan de arrancar) y permite entrar con "virsh console"
  # aunque falle la red
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

##############################################
# server2 — Ubuntu (cliente interno)
##############################################

# Clon ligero sobre la imagen base Ubuntu
resource "libvirt_volume" "ej5-server2-disk" {
  name             = "ej5-server2.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_ubuntu
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

# ISO cloud-init con la configuración inicial de server2
resource "libvirt_cloudinit_disk" "ej5-server2-cloudinit" {
  name           = "ej5-server2-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = file("${path.module}/cloud-init/user-data2.yaml")
  network_config = file("${path.module}/cloud-init/network-config2.yaml")
}

resource "libvirt_domain" "ej5-server2" {
  name   = "ej5-server2"
  memory = 1024
  vcpu   = 2

  # Sin qemu_agent: server2 no tiene salida a Internet y no puede instalar el agente

  # Red única: muy aislada (IP estática 10.0.0.2, gateway 10.0.0.1)
  network_interface {
    network_id = libvirt_network.ej5-muy-aislada.id
  }

  disk { volume_id = libvirt_volume.ej5-server2-disk.id }
  cloudinit = libvirt_cloudinit_disk.ej5-server2-cloudinit.id

  # Consola serie: las imágenes cloud la esperan (sin ella, algunas, como
  # Ubuntu, no terminan de arrancar) y permite entrar con "virsh console"
  # aunque falle la red
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
