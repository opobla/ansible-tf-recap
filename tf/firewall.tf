# Regla de firewall para permitir tráfico HTTP
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# Regla de firewall para permitir tráfico HTTPS (opcional)
resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# Regla de firewall para permitir tráfico SSH (para administración)
# Nota: Ya existe una regla SSH por defecto, pero creamos una específica para web-server
resource "google_compute_firewall" "allow_ssh_web" {
  name    = "allow-ssh-web-server"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# Output para mostrar las reglas creadas
output "firewall_rules" {
  value = {
    http_rule  = google_compute_firewall.allow_http.name
    https_rule = google_compute_firewall.allow_https.name
    ssh_rule   = google_compute_firewall.allow_ssh_web.name
  }
}
