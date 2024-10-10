# Usa la imagen base que prefieras
FROM python:3.12-slim-bookworm

# Establece el directorio de trabajo
WORKDIR /usr/src/app/workspace

# Actualiza los paquetes e instala Git y las dependencias necesarias para cv2
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 && \
    apt-get remove -y build-essential && apt-get autoremove -y && apt-get clean

# Instala las bibliotecas de Python que necesitas
RUN pip install --no-cache-dir \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn \
    scipy \
    opencv-python \
    notebook \
    tqdm \
    pillow

# Crea el usuario 'jc' y 'alvaro', utilizando las variables de entorno para las contraseñas
ARG JC_PASSWORD
ARG ALVARO_PASSWORD
RUN useradd -ms /bin/bash jc && \
    echo "jc:${JC_PASSWORD}" | chpasswd && \
    usermod -aG sudo jc && \
    useradd -ms /bin/bash alvaro && \
    echo "alvaro:${ALVARO_PASSWORD}" | chpasswd && \
    usermod -aG sudo alvaro

# Configura que jc y alvaro puedan usar sudo sin contraseña
RUN echo "jc ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "alvaro ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && visudo -c

# Cambia la propiedad de todos los archivos y directorios de /usr/src/app/workspace a jc y alvaro
RUN chown -R jc:jc /usr/src/app/workspace && \
    chown -R alvaro:alvaro /usr/src/app/workspace

# Establece el usuario jc como el usuario por defecto
USER jc

# Comando por defecto cuando inicie el contenedor
CMD ["bash", "-c", "cd /usr/src/app/workspace && bash"]
