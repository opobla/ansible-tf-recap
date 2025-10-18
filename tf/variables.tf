# Variables para la configuración de servidores
variable "servers" {
  description = "Configuración de servidores web"
  type = map(object({
    zone         = string
  }))
}

# Variable para el prefijo de nombres
variable "server_prefix" {
  description = "Prefijo para los nombres de servidores"
  type        = string
  default     = "web"
}

# Variable para el tipo de máquina por defecto
variable "default_machine_type" {
  description = "Tipo de máquina por defecto"
  type        = string
  default     = "e2-medium"
}

# Variable para el tamaño de disco por defecto
variable "default_disk_size" {
  description = "Tamaño de disco por defecto en GB"
  type        = number
  default     = 20
}

# Variable para la clave SSH
# Nota: el valor debe tener el formato: "usuario:ssh-rsa <clave_publica>"
variable "ssh_public_key" {
  description = "Clave pública SSH para acceso a las instancias"
  type        = string
}

# Variable para tags adicionales
variable "additional_tags" {
  description = "Tags adicionales para las instancias"
  type        = list(string)
  default     = ["managed-by-terraform", "auto-scaling-group"]
}

# Variable para el proyecto
variable "project_id" {
  description = "ID del proyecto de GCP"
  type        = string
}

# Variable para la región
variable "region" {
  description = "Región de GCP"
  type        = string
  default     = "europe-west1"
}

# Variable para la zona específica
variable "zone" {
  description = "Zona específica de GCP"
  type        = string
  default     = "europe-west1-b"
}
