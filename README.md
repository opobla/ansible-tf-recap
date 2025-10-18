# Ansible y Terraform: Despliegue automatizado en GCP

En esta práctica vamos a desplegar una infraestructura en Google Cloud Platform (GCP) utilizando Terraform para la creación de recursos y Ansible para su configuración.

El objetivo es crear varias máquinas virtuales en GCP y configurarlas automáticamente para ejecutar diferentes servicios.

## Pasos a seguir

1. Configurar las credenciales de autenticación con GCP
2. Crear la infraestructura base usando Terraform
3. Configurar las máquinas virtuales mediante Ansible
4. Verificar el correcto funcionamiento del despliegue

Antes de comenzar, asegúrate de tener instalados:
- Google Cloud SDK
- Terraform
- Ansible


## Configuración de las credenciales de autenticación

El comando `gcloud init` inicializa una nueva configuración de Google Cloud Platform (GCP). Durante el proceso:

1. Te pedirá autenticarte con tu cuenta de Google (preferiblemente la vinculada al proyecto GCP)
2. Seleccionarás el proyecto de GCP con el que quieres trabajar
3. Configurarás la región y zona por defecto para los recursos
4. Establecerá las credenciales que usará `gcloud` para todas sus operaciones posteriores

Este es el primer paso necesario para comenzar a trabajar con GCP desde la línea de comandos.
```
gcloud init
```

Las Application Default Credentials (ADC) son un mecanismo que proporciona Google Cloud para que las aplicaciones obtengan credenciales de autenticación de forma automática. Cuando una aplicación necesita autenticarse con Google Cloud, ADC busca las credenciales en varios lugares siguiendo este orden:

1. Variable de entorno GOOGLE_APPLICATION_CREDENTIALS
2. Credenciales proporcionadas por el comando `gcloud auth application-default login`
3. Credenciales de la cuenta de servicio asociada si se ejecuta en Google Cloud

Este sistema facilita el desarrollo local y el despliegue en la nube sin necesidad de modificar el código de la aplicación.

Para estableces las credenciales que usarán las aplicaciones por defecto debemos hacer:
```
gcloud auth application-default login
```
Esto es particularmente importante para que `terraform` sea capaz de autenticarse correctamente y realizar operaciones en nuestro nombre.

## Creación de la infraestructura con terraform

En el directorio `tf` encontrarás varios archivos de configuración de Terraform:

- `main.tf`: Contiene la configuración principal de los recursos a crear
- `variables.tf`: Define las variables que se utilizarán en la configuración. Cuidado porque este archivo tiene las variables pero **no sus valores**.
- `outputs.tf`: Especifica los valores que se mostrarán después de aplicar la configuración
- `terraform.tfvars.example`: Archivo opcional que contiene un ejemplo de los valores de las variables. **Es necesario modificar este archivo con los valores adecuados**.

Estos archivos trabajarán en conjunto para definir y gestionar la infraestructura como código.

- [ ] Haz una copia de `terraform.tfvars.example` en `terraform.tfvars`

```bash
cp terraform.tfvars.example terraform.tfvars
``` 

- [ ] Edita el archivo y coloca los valores adecuados según tu caso. En concreto:
  - `project_id`
  - `region`
  - `zone`
  - En el diccionario `servers` verifica así mismo las zonas en función de `zone`
  - `ssh_public_key`. Para esto tienes que tener un par de claves pública y privada. Se podrían reutilizar las que ya usamos para acceder a la máquina, pero también podemos generar un par para usar en nuestro ejemplo:

```bash
ssh-keygen -t rsa -b 4096 -f ./terraform-key -N ""
```

Ahora solo habría que trasladar la clave pública recién generada al archivo `terraform.tfvars` siguiendo el formato requerido: `usuario:ssh-rsa <clave_publica_completa>`. Para ello podemos hacerlo a mano o usar las siguientes órdenes en la bash:

```bash
awk -v user=$(whoami) -v key="$(cat terraform-key.pub | cut -d' ' -f1,2)" '
/^ssh_public_key/ { 
    print "ssh_public_key = \"" user ":" key "\""
    next 
}
{ print }
' terraform.tfvars > temp
mv temp terraform.tfvars
```
- [ ] Comprueba que `terraform.tfvars` tiene los valores adecuados

## Despliege con Terraform

Una vez configuradas las variables, el primer paso es inicializar el directorio de trabajo de Terraform con:

```bash
terraform init
``` 

Este comando inicializa el directorio de trabajo de Terraform. Durante la inicialización:

- Descarga los plugins necesarios para los proveedores definidos en la configuración (en nuestro caso, el proveedor de Google Cloud)
- Inicializa el backend donde se almacenará el estado de la infraestructura
- Verifica la sintaxis básica de los archivos de configuración
- Prepara el directorio de trabajo para ejecutar otros comandos de Terraform

Es necesario ejecutar `terraform init` la primera vez que se trabaja con una configuración nueva de Terraform o cuando se añaden/modifican proveedores.

El siguiente paso es ejecutar:
```bash
terraform plan
```

Este comando muestra un plan de ejecución, es decir, muestra los cambios que Terraform va a realizar en la infraestructura antes de aplicarlos realmente. Durante esta fase:

- Terraform lee el estado actual de cualquier objeto remoto ya existente para asegurarse de que tiene información actualizada
- Compara el estado actual con la configuración deseada definida en los archivos
- Muestra las diferencias y detalla qué acciones tomará para alcanzar el estado deseado:
  - Qué recursos se van a crear (marcados con `+`)
  - Qué recursos se van a modificar (marcados con `~`) 
  - Qué recursos se van a destruir (marcados con `-`)

Es una buena práctica revisar siempre el plan antes de aplicar los cambios para asegurarse de que las modificaciones previstas son las esperadas.

Una vez revisado el plan, podemos aplicar los cambios con:

```bash
terraform apply
```

Este comando aplica los cambios necesarios para alcanzar el estado deseado de la configuración. Durante esta fase:

- Terraform ejecuta el plan que se mostró anteriormente
- Realiza las llamadas necesarias a las APIs de los proveedores para crear, modificar o eliminar recursos
- Actualiza el estado de la infraestructura en el backend
- Muestra un resumen de los cambios realizados

Por seguridad, Terraform pedirá confirmación antes de aplicar los cambios. Se puede evitar esta confirmación usando el flag `-auto-approve`:

## Obtención del inventario de máquinas para Ansible

A continuación vamos a configurar Ansible para el aprovisionamiento de las máquinas. Para ello nos situamos en el directorio `ansible` de este repositorio.

Para poder administrar nuestras máquinas con Ansible necesitamos un archivo de inventario que vamos a construir con las máquinas que acabamos de crear con terraform. Para ello usaremos el script `build_inventory`

```bash
bash build_inventory.sh > inventory.ini
```

Este script obtiene las direcciones IP de las máquinas creadas por Terraform y genera un archivo de inventario en formato INI para Ansible. El archivo de inventario resultante (`inventory.ini`) contendrá las direcciones IP de nuestras máquinas agrupadas según su rol.

El formato del archivo de inventario será similar a:

```ini
[web_servers]
web-1 ansible_host="34.79.15.105"
web-2 ansible_host="34.78.143.141"
web-3 ansible_host="34.77.52.107"
web-4 ansible_host="35.205.78.186"
web-5 ansible_host="35.190.202.3"
[web_servers:vars]
ansible_user=ogarcia
ansible_ssh_private_key_file=../tf/terraform-key
```

`ansible_ssh_private_key_file` es una variable de Ansible que especifica la ruta al archivo de clave privada SSH que se utilizará para autenticarse en los hosts remotos. En este caso, apunta a la clave privada generada por Terraform (terraform-key) que se encuentra en el directorio `../tf/`


## Probando la conectividad con Ansible

Una vez generado el inventario, podemos verificar que Ansible puede conectarse correctamente a todas las máquinas usando el módulo `ping`:

```bash
export ANSIBLE_HOST_KEY_CHECKING=False
ansible -m ping -i inventory.ini web_servers
```

La variable de entorno `ANSIBLE_HOST_KEY_CHECKING=False` deshabilita la verificación de claves SSH del host. Esto significa que:

- Ansible no verificará ni almacenará las claves SSH de los hosts remotos
- No preguntará para confirmar la autenticidad de los hosts al conectarse por primera vez
- Evita el mensaje típico "The authenticity of host ... can't be established"

Esto es útil en entornos de prueba o cuando las máquinas se crean y destruyen frecuentemente, pero **no se recomienda en entornos de producción** ya que reduce la seguridad al omitir la verificación de identidad de los hosts.

Para entornos de producción es mejor gestionar adecuadamente las claves SSH de los hosts y mantener esta verificación activada.

## Ejecutando el primer playbook

Un playbook de Ansible es un archivo YAML que define un conjunto de tareas y configuraciones que se ejecutarán en los hosts remotos. Los playbooks son la forma en que Ansible orquesta el despliegue, la configuración y la administración de sistemas.

Los playbooks pueden:

- Instalar y configurar software
- Desplegar aplicaciones 
- Gestionar usuarios y permisos
- Ejecutar comandos y scripts
- Manejar servicios del sistema
- Copiar archivos y templates
- Y prácticamente cualquier tarea de administración de sistemas

Un playbook simple tiene esta estructura básica:
```yaml
# Playbook simple para servidores web
# Este playbook instala nginx y configura una página web básica

- name: Configurar servidores web
  hosts: web_servers
  become: yes

  tasks:
    - name: Actualizar paquetes del sistema      # Nombre descriptivo de la tarea
      apt:                                       # Módulo de Ansible para gestionar paquetes apt
        update_cache: yes                        # Equivalente a ejecutar 'apt-get update'

    - name: Instalar nginx
      apt:
        name: nginx
        state: present

    - name: Iniciar y habilitar nginx
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Crear página web personalizada
      copy:
        content: |
          <h1>Bienvenido al Servidor {{ inventory_hostname }}</h1>
          <p>IP: {{ ansible_host }}</p>
          <p>Servidor gestionado por Ansible</p>
        dest: /var/www/html/index.html
        owner: www-data
        group: www-data
        mode: '0644'

    - name: Mostrar información del servidor
      debug:
        msg: "Servidor {{ inventory_hostname }} configurado correctamente"
```

Este playbook realiza las siguientes tareas:

1. **Definición del playbook**: 
   - `name`: Define el nombre descriptivo "Configurar servidores web"
   - `hosts`: Especifica que se ejecutará en los hosts del grupo "web_servers"
   - `become: yes`: Indica que las tareas se ejecutarán con privilegios de superusuario (sudo)

2. **Actualización del sistema**:
   - Usa el módulo `apt` para actualizar la caché de paquetes
   - Equivalente a ejecutar `apt-get update`

3. **Instalación de nginx**:
   - Utiliza el módulo `apt` para instalar el servidor web nginx
   - `state: present` asegura que el paquete esté instalado

4. **Configuración del servicio nginx**:
   - Usa el módulo `service` para:
     - Iniciar el servicio (`state: started`)
     - Habilitarlo para que inicie con el sistema (`enabled: yes`)

5. **Creación de página web**:
   - Utiliza el módulo `copy` para crear un archivo HTML
   - Usa variables de Ansible como `{{ inventory_hostname }}` y `{{ ansible_host }}`
   - Establece permisos y propietario apropiados para el archivo

6. **Información de finalización**:
   - Usa el módulo `debug` para mostrar un mensaje de confirmación
   - Confirma que el servidor ha sido configurado correctamente

Este playbook es un ejemplo básico pero completo de cómo Ansible puede automatizar la configuración de servidores web.

