# Plantillas HTML para Sitio Web Estático

Este directorio contiene las plantillas Jinja2 utilizadas por el playbook `static-website.yml` para generar las páginas HTML del sitio web.

## Estructura de Archivos

### Plantillas HTML

- **`index.html.j2`** - Página principal del sitio web
  - Diseño moderno con gradientes y efectos visuales
  - Información del servidor y estado
  - Navegación a otras páginas
  - Responsive design

- **`404.html.j2`** - Página de error 404 personalizada
  - Diseño atractivo para errores
  - Información del servidor
  - Enlace de regreso al inicio
  - Animaciones CSS

- **`about.html.j2`** - Página "Acerca de"
  - Información sobre el proyecto
  - Stack tecnológico utilizado
  - Características del proyecto
  - Información del servidor

- **`contact.html.j2`** - Página de contacto
  - Formulario de contacto
  - Información de contacto
  - Datos del servidor
  - Diseño interactivo

### Variables Disponibles

Las plantillas tienen acceso a las siguientes variables de Ansible:

#### Variables del Sistema
- `{{ inventory_hostname }}` - Nombre del host en el inventario
- `{{ ansible_host }}` - IP del servidor
- `{{ ansible_date_time.date }}` - Fecha actual
- `{{ ansible_date_time.time }}` - Hora actual
- `{{ ansible_date_time.iso8601 }}` - Fecha y hora en formato ISO
- `{{ ansible_zone }}` - Zona de GCP (si está disponible)

#### Variables Configurables
- `{{ site_name }}` - Nombre del sitio web
- `{{ site_domain }}` - Dominio del sitio
- `{{ company_name }}` - Nombre de la empresa
- `{{ contact_email }}` - Email de contacto
- `{{ contact_phone }}` - Teléfono de contacto
- `{{ nginx_version }}` - Versión de Nginx instalada

## Uso de las Plantillas

### Ejecutar el Playbook

```bash
# Ejecutar con configuración por defecto
ansible-playbook -i inventory.ini static-website.yml

# Ejecutar con variables personalizadas
ansible-playbook -i inventory.ini static-website.yml \
  -e "site_name='Mi Empresa' site_domain='miempresa.com'"

# Ejecutar solo en un servidor específico
ansible-playbook -i inventory.ini static-website.yml --limit web-1
```

### Personalizar Variables

Puedes personalizar las variables en el playbook o pasarlas como parámetros:

```yaml
vars:
  site_name: "Mi Sitio Personalizado"
  company_name: "Mi Empresa S.L."
  contact_email: "info@miempresa.com"
  contact_phone: "+34 900 000 000"
```

## Características de las Plantillas

### Diseño Responsivo
- Todas las plantillas están optimizadas para dispositivos móviles
- Uso de CSS Grid y Flexbox para layouts adaptativos
- Gradientes y efectos visuales modernos

### Accesibilidad
- Estructura semántica HTML5
- Contraste de colores adecuado
- Navegación clara y consistente

### Performance
- CSS inline para carga rápida
- Optimización de imágenes y recursos
- Código HTML limpio y eficiente

### Seguridad
- Sanitización de variables en las plantillas
- Headers de seguridad configurados en Nginx
- Validación de inputs en formularios

## Personalización

### Modificar Estilos
Edita los archivos `.j2` para cambiar:
- Colores y gradientes
- Tipografías
- Espaciado y layout
- Efectos visuales

### Agregar Nuevas Páginas
1. Crea un nuevo archivo `.j2` en el directorio `templates/`
2. Agrega una tarea en el playbook para procesar la plantilla
3. Actualiza la navegación en las otras plantillas

### Variables Personalizadas
Agrega nuevas variables en la sección `vars` del playbook y úsalas en las plantillas.

## Estructura del Sitio Web Generado

```
/var/www/html/
├── index.html          # Página principal
├── about.html          # Página "Acerca de"
├── contact.html        # Página de contacto
├── 404.html           # Página de error 404
├── robots.txt         # Archivo para motores de búsqueda
├── assets/            # Directorio para recursos estáticos
└── images/            # Directorio para imágenes
```

## Troubleshooting

### Problemas Comunes

1. **Plantilla no se encuentra**
   - Verifica que el archivo esté en el directorio `templates/`
   - Comprueba la ruta en la tarea del playbook

2. **Variables no se renderizan**
   - Verifica que la variable esté definida en `vars`
   - Comprueba la sintaxis de Jinja2 `{{ variable }}`

3. **Permisos incorrectos**
   - Las plantillas se crean con permisos 0644
   - Propietario: www-data, Grupo: www-data

### Debugging

```bash
# Verificar sintaxis de las plantillas
ansible-playbook -i inventory.ini static-website.yml --check

# Ejecutar con verbose para ver detalles
ansible-playbook -i inventory.ini static-website.yml -v

# Verificar conectividad antes de ejecutar
ansible web_servers -m ping
```

