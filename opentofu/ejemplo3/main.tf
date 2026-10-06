# Clon ligero sobre la imagen base: solo almacena los cambios diferenciales
resource "libvirt_volume" "ej3-server1-disk" {
  name             = "ej3-server1.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

# Disco adicional vacío de 1 GB
resource "libvirt_volume" "ej3-server1-disk-extra1" {
  name   = "ej3-server1-disk-extra1.qcow2"
  pool   = var.libvirt_pool_name
  format = "qcow2"
  size   = 1 * 1024 * 1024 * 1024 # 1 GB en bytes
}

# ISO cloud-init con la configuración inicial de la máquina
resource "libvirt_cloudinit_disk" "ej3-server1-cloudinit" {
  name           = "ej3-server1-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = file("${path.module}/cloud-init/user-data1.yaml")
  network_config = file("${path.module}/cloud-init/network-config1.yaml")
}

# Definición del dominio (máquina virtual)
resource "libvirt_domain" "ej3-server1" {
  name   = "ej3-server1"
  memory = 1024
  vcpu   = 2

  # Pide las IP al agente de QEMU (qemu-guest-agent): así se conocen también las estáticas
  qemu_agent = true

  # Red 1: NAT con DHCP (acceso exterior)
  network_interface {
    network_id     = libvirt_network.ej3-nat-dhcp.id
    wait_for_lease = true
  }

  # Red 2: default (red de gestión del host)
  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk { volume_id = libvirt_volume.ej3-server1-disk.id }
  disk { volume_id = libvirt_volume.ej3-server1-disk-extra1.id }
  cloudinit = libvirt_cloudinit_disk.ej3-server1-cloudinit.id

  # Consola serie: las imágenes cloud la esperan (sin ella, algunas, como
  # Ubuntu, no terminan de arrancar) y permite entrar con "virsh console"
  # aunque falle la red
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
