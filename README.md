# Ejercicios del Proyecto Integrado

Repositorio con los ejercicios prácticos del módulo de **Proyecto Integrado**.

## Estructura

### `ansible/` — Automatización con Ansible

- **`ejercicio1/`** — Playbook básico: actualización del sistema, instalación de paquetes, copia de ficheros y uso de templates Jinja2.
- **`ejercicio2/`** — Playbook con roles: organización en roles `commons`, `apache2` y `mariadb`, con handlers, templates y ficheros de configuración propios de cada rol.

### `opentofu/` — Infraestructura como código con OpenTofu + libvirt

Todos los ejemplos usan clones ligeros (backing store) sobre una imagen base qcow2 y cloud-init para la configuración inicial. Los nombres de recursos llevan el prefijo `ejN-` para evitar conflictos entre ejemplos.

Imágenes base (en el pool `default`): `debian13-base.qcow2` y `ubuntu2604-base.qcow2`. Los dominios usan `qemu_agent = true`, así que OpenTofu obtiene las IP (también las estáticas) del agente `qemu-guest-agent`, que instala cloud-init. El provider está fijado a `dmacvicar/libvirt` 0.8.3, la última versión con esta sintaxis: desde la 0.9 el provider se ha reescrito y usa otra. En los ficheros `user-data` hay que sustituir la línea de ejemplo de `ssh-authorized-keys` por tu clave pública.

- **`ejemplo1/`** — 1 VM Debian. Red `default` con DHCP. Introducción básica a OpenTofu con libvirt.

- **`ejemplo2/`** — 1 VM Debian. Red `default` con DHCP. Añade un disco extra de 1 GB.

- **`ejemplo3/`** — 1 VM Debian con 2 interfaces de red: NAT con DHCP (`ej3-nat-dhcp`) y red `default`. Disco extra de 1 GB. Introduce la definición de redes con `network.tf` y la configuración de red via cloud-init (`network-config`).

- **`ejemplo4/`** — 1 VM Debian con 2 interfaces: NAT con DHCP (`ej4-nat-dhcp`) y red aislada sin DHCP (`ej4-aislada-static`, IP estática 192.168.130.10). Disco extra de 1 GB. 

- **`ejemplo5/`** — 2 VMs: server1 (Debian) y server2 (Ubuntu). Server1 tiene acceso exterior vía NAT (`ej5-nat-dhcp`) y conectividad interna en red muy aislada (`ej5-muy-aislada`, 10.0.0.1). Server2 solo tiene red muy aislada (10.0.0.2, gateway 10.0.0.1). Server1 no tiene activado el reenvío de paquetes ni el NAT, así que server2 no tiene salida al exterior. Por eso, en `user-data2.yaml` están comentadas la instalación de paquetes y la actualización, y server2 no usa `qemu_agent`. Además, `inventario.tf` genera con `templatefile` el inventario de Ansible (`hosts`) a partir de las IP del escenario.
