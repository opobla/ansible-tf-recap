# Configuración del proveedor
provider "google" {
  project = var.project_id
  region  = var.region
  zone = var.zone
}

# Output para mostrar la zona utilizada
output "GCP_project_and_zone" {
  value = "Project: ${var.project_id}, Region: ${var.region}, Zone: ${var.zone}"
}
