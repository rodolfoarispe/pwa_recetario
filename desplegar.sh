#!/bin/bash

# === CONFIGURACIÓN ===
USER="rodol"
HOST="192.168.0.14"         # Ej: 192.168.1.100
REMOTE_DIR="/inetpub/recetario"  # Ej: /home/user/mi-app o /mnt/c/proyectos/mi-app-web
APP_NAME="recetario"
LOCAL_DIR="."                  # Carpeta actual donde estás
REMOTE_WIN=$(echo "$REMOTE_DIR" | sed 's@/@\\@g')


echo "🚀 Iniciando despliegue desde tu Mac..."
echo "📁 Origen local: $LOCAL_DIR"
echo "📡 Destino remoto: $USER@$HOST:$REMOTE_DIR"

# 1. Copiar archivos a M2
echo "🔗 Copiando archivos a $USER@$HOST..."
scp -r "$LOCAL_DIR"/* "$USER@$HOST:$REMOTE_DIR/"

# 2. Conectar por SSH y hacer todo lo demás en M2
echo "🔌 Conectando a $HOST y configurando contenedor Docker..."
# recuerda que EOF sin comillas significa que todo se interpreta en ambiente local primero mientras que con comillas se interpresta remoto
ssh "$USER@$HOST" << EOF 

    @rem "Cambiar al directorio destino"
    cd "$REMOTE_DIR"

    @echo "📂 Directorio actual en M2: %cd%"

    rem Detener y eliminar contenedor anterior (si existe)
    @echo "🛑 Deteniendo y eliminando contenedor anterior (si existe)..."
    docker stop "$APP_NAME" 
    docker rm "$APP_NAME" 

    REM Levantar nuevo contenedor con volumen apuntando a este directorio
    @echo "🐋 Levantando contenedor Docker..."
    docker run -d \
    --name "$APP_NAME" \
    -p 8443:443 \
    -v "%cd%":/usr/share/nginx/html \
    -v "%cd%/nginx.conf":/etc/nginx/nginx.conf:ro \
    -v "%cd%/certs":/etc/nginx/ssl:ro \
    --restart unless-stopped \
    nginx

    REM Recargar Nginx para aplicar cambios
    @echo "🔄 Recargando Nginx..."
    docker exec -t "$APP_NAME" nginx -s reload

    @echo "✅ Contenedor listo. Tu app está siendo servida desde $REMOTE_WIN"

EOF

echo "🎉 Despliegue completado. Accede a tu app en:"
echo "http://$HOST"