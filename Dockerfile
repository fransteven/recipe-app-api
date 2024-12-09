# Usa una imagen base de Python 3.9 basada en Alpine Linux 3.13
# Alpine es una imagen ligera ideal para entornos de producción
FROM python:3.9-alpine3.13

# Especifica el responsable del mantenimiento de esta imagen
LABEL maintainer="londonappdeveloper.com"

# Establece una variable de entorno para evitar que Python almacene su salida en búfer
# Esto asegura que los logs se muestren inmediatamente en la consola
ENV PYTHONUNBUFFERED 1

# Copia el archivo de dependencias de producción al directorio temporal del contenedor
COPY ./requirements.txt /tmp/requirements.txt
# Copia el archivo de dependencias de desarrollo al directorio temporal del contenedor
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copia el código fuente de la aplicación al directorio `/app` dentro del contenedor
COPY ./app /app

# Establece el directorio de trabajo dentro del contenedor como `/app`
# Todos los comandos subsecuentes se ejecutarán desde este directorio
WORKDIR /app

# Expone el puerto 8000 del contenedor para que pueda aceptar conexiones externas
EXPOSE 8000

# Define un argumento de construcción con valor por defecto `false`
# Este argumento se usará para decidir si se instalan dependencias adicionales para desarrollo
ARG DEV=false

# Realiza múltiples tareas en un único comando RUN para reducir el número de capas en la imagen:
# 1. Crea un entorno virtual en `/py`.
# 2. Actualiza `pip` a la última versión dentro del entorno virtual.
# 3. Instala las dependencias del archivo `requirements.txt`.
# 4. Si el argumento `DEV` es `true`, instala las dependencias de desarrollo desde `requirements.dev.txt`.
# 5. Elimina los archivos temporales del contenedor para ahorrar espacio.
# 6. Crea un usuario llamado `django-user` sin contraseña y sin directorio de inicio (mejora la seguridad).
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ;\
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Añade el directorio del entorno virtual al PATH del contenedor
# Esto permite usar comandos como `python` y `pip` directamente sin especificar su ruta completa
ENV PATH="/py/bin:$PATH"

# Cambia el usuario activo del contenedor a `django-user`
# Esto evita que el contenedor se ejecute como root, mejorando la seguridad
USER django-user
