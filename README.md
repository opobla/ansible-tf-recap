- [ ] Hacer login ssh en operaciones

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

Para poder administrar nuestras máquinas con Ansible necesitamos un archivo de inventario que vamos a construir con las máquinas que acabamos de crear con terraform.



