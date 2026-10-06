# Pool de almacenamiento donde se crean los volúmenes (disco y cloud-init)
variable "libvirt_pool_name" {
  type        = string
  description = "Nombre del pool de almacenamiento libvirt."
  default     = "default"
}

# Imagen base Debian para server1
variable "base_image_debian" {
  type        = string
  description = "Nombre de la imagen base Debian en el pool."
  default     = "debian13-base.qcow2"
}

# Imagen base Ubuntu para server2
variable "base_image_ubuntu" {
  type        = string
  description = "Nombre de la imagen base Ubuntu en el pool."
  default     = "ubuntu2604-base.qcow2"
}
