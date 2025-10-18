# Seguridad en Terraform: Gestión de Datos Sensibles

## Introducción

Este documento explica las mejores prácticas de seguridad para el manejo de datos sensibles en proyectos de Terraform, enfocándose en la protección de información confidencial y la prevención de exposición accidental de credenciales.

## ¿Por Qué No Distribuir Archivos con Datos Sensibles?

### Riesgos de Seguridad

#### 1. **Exposición de Credenciales**
Los archivos `terraform.tfvars` y similares frecuentemente contienen:
- Claves SSH privadas o públicas
- Tokens de API de servicios cloud
- Contraseñas de bases de datos
- Certificados y claves de cifrado
- URLs de conexión con credenciales embebidas

#### 2. **Acceso No Autorizado**
Una vez que los datos sensibles están en el control de versiones:
- **Historial permanente**: Los datos quedan en el historial de Git para siempre
- **Acceso amplio**: Cualquier persona con acceso al repositorio puede ver los datos
- **Distribución involuntaria**: Los datos se replican en clones y forks del repositorio

#### 3. **Violaciones de Compliance**
- **GDPR**: Exposición de datos personales
- **SOX**: Violación de controles financieros
- **HIPAA**: Exposición de datos de salud
- **PCI DSS**: Exposición de datos de tarjetas de crédito

### Casos Reales de Incidentes

#### Ejemplos Documentados:
- **GitHub 2020**: Repositorios con tokens de API expuestos
- **AWS 2019**: Claves de acceso en repositorios públicos
- **Azure 2021**: Certificados de servicio en código fuente

## Mejores Prácticas de Seguridad

### 1. **Separación de Configuración y Datos**

#### Archivos Seguros para Control de Versiones:
```hcl
# variables.tf - Solo definiciones
variable "project_id" {
  description = "ID del proyecto de GCP"
  type        = string
}

# terraform.tfvars.example - Solo ejemplos
project_id = "ejemplo-proyecto"
```

#### Archivos que NUNCA deben versionarse:
```
terraform.tfvars          # ❌ Contiene datos reales
*.tfvars                  # ❌ Archivos de variables con datos
.terraform/               # ❌ Estado local
*.tfstate                 # ❌ Estado de infraestructura
```

### 2. **Gestión de Secretos**

#### Variables de Entorno:
```bash
# Configuración mediante variables de entorno
export TF_VAR_project_id="mi-proyecto-real"
export TF_VAR_ssh_public_key="usuario:ssh-rsa clave-real"
```

#### Archivos de Configuración Local:
```bash
# terraform.tfvars.local (NO versionado)
project_id = "proyecto-real"
ssh_public_key = "usuario:ssh-rsa clave-real"
```

### 3. **Configuración de .gitignore**

#### Configuración Completa:
```gitignore
# Archivos de estado
*.tfstate
*.tfstate.*
*.tfstate.backup

# Archivos de variables sensibles
terraform.tfvars
*.tfvars
!terraform.tfvars.example

# Archivos de plan
*.tfplan
*.tfplan.*

# Directorio de plugins
.terraform/

# Archivos de credenciales
*.pem
*.key
*.crt
*.p12
*.pfx

# Archivos de configuración local
.env
.env.local
secrets/
```

### 4. **Estrategias de Gestión de Secretos**

#### Para Desarrollo:
- Variables de entorno locales
- Archivos `.tfvars.local` (en .gitignore)
- Herramientas como `direnv` para carga automática

#### Para Producción:
- **HashiCorp Vault**: Gestión centralizada de secretos
- **AWS Secrets Manager**: Integración nativa con AWS
- **Azure Key Vault**: Gestión de secretos en Azure
- **Google Secret Manager**: Gestión de secretos en GCP

### 5. **Validación de Seguridad**

#### Herramientas de Análisis:
```bash
# Detección de secretos en el código
git-secrets --scan
trufflehog --regex --entropy=False .

# Análisis de vulnerabilidades
checkov -d .
tfsec .
```

#### Pre-commit Hooks:
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
```

## Configuración por Entornos

### Estructura Recomendada:
```
terraform/
├── environments/
│   ├── dev/
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── prod/
│       ├── terraform.tfvars
│       └── backend.tf
├── modules/
├── variables.tf
└── main.tf
```

### Configuración de Backend Seguro:
```hcl
# backend.tf
terraform {
  backend "gcs" {
    bucket = "mi-bucket-terraform-state"
    prefix = "infrastructure/prod"
    encryption_key = "projects/mi-proyecto/locations/global/keyRings/terraform/cryptoKeys/state"
  }
}
```

## Monitoreo y Auditoría

### Logging de Acceso:
- **CloudTrail**: Registro de cambios en infraestructura
- **Audit Logs**: Seguimiento de accesos a secretos
- **Git History**: Monitoreo de cambios en configuración

### Alertas de Seguridad:
- **Detección de secretos**: Alertas automáticas
- **Acceso anómalo**: Monitoreo de patrones de acceso
- **Cambios no autorizados**: Alertas de modificaciones

## Recuperación de Incidentes

### Si se Exponen Datos Sensibles:

#### 1. **Respuesta Inmediata:**
```bash
# Eliminar archivos del historial
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch terraform.tfvars' \
  --prune-empty --tag-name-filter cat -- --all

# Forzar actualización del repositorio
git push origin --force --all
```

#### 2. **Rotación de Credenciales:**
- Cambiar todas las claves SSH
- Rotar tokens de API
- Regenerar certificados
- Actualizar contraseñas

#### 3. **Auditoría Post-Incidente:**
- Revisar logs de acceso
- Identificar datos expuestos
- Evaluar impacto
- Implementar medidas preventivas

## Herramientas Recomendadas

### Gestión de Secretos:
- **HashiCorp Vault**: Estándar de la industria
- **AWS Secrets Manager**: Para entornos AWS
- **Azure Key Vault**: Para entornos Azure
- **Google Secret Manager**: Para entornos GCP

### Análisis de Seguridad:
- **Checkov**: Análisis de infraestructura
- **Tfsec**: Análisis específico de Terraform
- **TruffleHog**: Detección de secretos
- **Git-secrets**: Prevención de commits con secretos

### Monitoreo:
- **GitGuardian**: Monitoreo de secretos en repositorios
- **Snyk**: Análisis de vulnerabilidades
- **SonarQube**: Análisis de calidad y seguridad

## Conclusiones

La gestión segura de datos sensibles en Terraform requiere:

1. **Separación clara** entre configuración y datos sensibles
2. **Herramientas apropiadas** para gestión de secretos
3. **Procesos establecidos** para rotación y auditoría
4. **Monitoreo continuo** de la exposición de datos
5. **Capacitación del equipo** en mejores prácticas de seguridad

La implementación de estas prácticas no solo protege la infraestructura, sino que también cumple con regulaciones de compliance y reduce significativamente el riesgo de incidentes de seguridad.

## Recursos Adicionales

- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/security.html)
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security/security-advisories)
