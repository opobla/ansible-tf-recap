# Configuración para crear múltiples servidores usando for_each
resource "google_compute_instance" "debian_servers" {
  for_each     = var.servers
  name         = each.key
  machine_type = var.default_machine_type # Todas son del mismo tipo
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = var.default_disk_size # Todas son del mismo tamaño
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # IP externa efímera
    }
  }

  metadata = {
    ssh-keys = var.ssh_public_key
  }

  tags = concat(
    ["web-server", "debian"], var.additional_tags
  )

  labels = {
    managed-by  = "terraform"
    server-id   = each.key
  }
}

# Outputs para los servidores creados con for_each
output "servidores_web" {
  description = "Información de servidores creados con for_each"
  value = {
    for k, v in google_compute_instance.debian_servers : k => {
      name         = v.name
      external_ip  = v.network_interface[0].access_config[0].nat_ip
      internal_ip  = v.network_interface[0].network_ip
      zone         = v.zone
    }
  }
}


# Output con todas las IPs externas
output "all_external_ips" {
  description = "Todas las IPs externas de los servidores"
  value = concat(
    [for k, v in google_compute_instance.debian_servers : v.network_interface[0].access_config[0].nat_ip],
  )
}



