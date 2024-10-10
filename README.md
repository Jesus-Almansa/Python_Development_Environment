# Proyecto Docker con Usuarios y Permisos para Desarrollo Colaborativo

Este proyecto incluye un entorno de desarrollo configurado con Docker para gestionar múltiples usuarios (`jc` y `alvaro`), asegurando que ambos tengan permisos completos sobre los archivos y puedan realizar operaciones de Git desde dentro del contenedor sin problemas de permisos. Se utiliza Docker y Docker Compose para crear un entorno colaborativo donde los usuarios puedan modificar y trabajar en los archivos de manera fluida.

## Características

- **Dockerfile** configurado para crear dos usuarios: `jc` y `alvaro`.
- Ambos usuarios tienen permisos de `sudo` sin necesidad de contraseña.
- Los archivos en el directorio de trabajo se configuran automáticamente para pertenecer a `jc` y tener permisos adecuados.
- El directorio del proyecto y los archivos `.git` son accesibles por `jc` para operaciones de Git desde dentro del contenedor.
- Uso de variables de entorno para gestionar las contraseñas de los usuarios de manera segura.

## Requisitos

- Docker (version 19.x o superior)
- Docker Compose (version 1.27.x o superior)

## Configuración

### Paso 1: Clona el repositorio

```bash
git clone <URL del repositorio>
cd <nombre del proyecto>
```

### Paso 2: Configura las variables de entorno

En la raíz del proyecto, crea un archivo `.env` para almacenar las contraseñas de los usuarios de forma segura:

```bash
# .env
JC_PASSWORD=mi_contraseña_segura_jc
ALVARO_PASSWORD=mi_contraseña_segura_alvaro
```

**Nota**: Asegúrate de no subir este archivo al repositorio. Ya está añadido en `.gitignore` para evitar que se suba por error.

### Paso 3: Construir y levantar el contenedor

Ejecuta el siguiente comando para construir la imagen y levantar el contenedor usando `docker-compose`:

```bash
docker-compose build --no-cache
docker-compose up
```

### Paso 4: Verificar la configuración

Una vez que el contenedor esté en funcionamiento, puedes acceder al contenedor usando:

```bash
docker exec -it pruebas_usuario2 bash
```

Dentro del contenedor, verifica que los usuarios `jc` y `alvaro` existen y que ambos tienen acceso a los archivos del proyecto.

### Estructura de archivos

```bash
.
├── Dockerfile              # Configuración para construir el entorno Docker
├── docker-compose.yml      # Configuración para levantar el contenedor y pasar variables de entorno
├── .env                    # Archivo que contiene las contraseñas de los usuarios
└── workspace               # Directorio de trabajo donde están los archivos del proyecto
```

## Detalles del Dockerfile

- **Crea usuarios `jc` y `alvaro`**: Estos usuarios son creados durante la construcción del contenedor. Se utiliza la variable de entorno para configurar sus contraseñas.
  
  ```Dockerfile
  ARG JC_PASSWORD
  ARG ALVARO_PASSWORD
  RUN useradd -ms /bin/bash jc && \
      echo "jc:${JC_PASSWORD}" | chpasswd && \
      usermod -aG sudo jc && \
      useradd -ms /bin/bash alvaro && \
      echo "alvaro:${ALVARO_PASSWORD}" | chpasswd && \
      usermod -aG sudo alvaro
  ```

- **Permisos de usuario**: Cambia la propiedad de todos los archivos del directorio de trabajo (`/usr/src/app/workspace`) a `jc` para que tenga control total sobre ellos.

  ```Dockerfile
  RUN chown -R jc:jc /usr/src/app/workspace
  ```

- **Permisos del proyecto Git**: Se asegura de que todos los archivos y directorios dentro del proyecto tengan los permisos correctos para que `jc` pueda realizar operaciones de Git sin problemas.

  ```Dockerfile
  RUN find /usr/src/app/workspace -type d -exec chmod 755 {} \; && \
      find /usr/src/app/workspace -type f -exec chmod 644 {} \;
  ```

## Detalles del `docker-compose.yml`

El archivo `docker-compose.yml` automatiza la configuración y ejecución del contenedor, utilizando las variables de entorno definidas en el archivo `.env`.

- **`env_file`**: Carga las variables de entorno desde el archivo `.env`, incluyendo las contraseñas de los usuarios.
  
  ```yaml
  env_file:
    - .env
  ```

- **`build.args`**: Pasa las contraseñas como argumentos de construcción al contenedor.

  ```yaml
  build:
    context: .
    args:
      JC_PASSWORD: ${JC_PASSWORD}
      ALVARO_PASSWORD: ${ALVARO_PASSWORD}
  ```

- **Volúmenes**: Monta el directorio local de desarrollo en el contenedor para asegurar que los cambios realizados en los archivos se sincronicen.

  ```yaml
  volumes:
    - /home/j/Desarrollo/PRUEBAS:/usr/src/app/workspace
  ```

## Uso de Git dentro del contenedor

Una vez que estás dentro del contenedor como `jc`, puedes ejecutar operaciones de Git sin problemas de permisos:

```bash
git add .
git commit -m "Tu mensaje de commit"
git push
```

### Notas importantes

- El archivo `.env` debe estar siempre en tu máquina local y **no debe ser subido** al repositorio para evitar exponer tus contraseñas.
- Si añades nuevos archivos al directorio montado, asegúrate de que tengan los permisos correctos utilizando `chown` o `chmod` si es necesario.