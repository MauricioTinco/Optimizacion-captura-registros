#!/bin/bash
# Script universal para captura de logs y snapshot del sistema Alfresco
# Compatible con Ubuntu, Debian, CentOS y Red Hat

# Detectar sistema operativo
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "No se pudo detectar el sistema operativo. Abortando."
    exit 1
fi

echo "Sistema operativo detectado: $OS"

# Fecha actual
FECHA=$(date +%Y-%m-%d)

# Crear carpetas
mkdir -p logs-$FECHA/alfresco
mkdir -p logs-$FECHA/solr
mkdir -p logs-$FECHA/transformation
mkdir -p logs-$FECHA/activemq
mkdir -p logs-$FECHA/recurso
mkdir -p logs-$FECHA/sistema

# Definir rutas
CATALINA_LOG_FILE="/alfresco/alfresco-23.2/tomcat/logs/catalina.out"
SOLR_LOG_FILE="/alfresco/alfresco-search-services/logs/solr.log"
TRANSFORM_SERVICE_LOG_DIR="/alfresco/alfresco-transform-service/logs/"
ACTIVEMQ_LOG_FILE="/alfresco/activemq/data/activemq.log"

# Archivos de salida
RECURSO_OUTPUT_FILE=logs-$FECHA/recurso/snapshot-comando.txt
SERVICES_STATUS_FILE=logs-$FECHA/sistema/status_servicios.txt
CONEXIONES_FILE=logs-$FECHA/sistema/conexiones.txt

# Capturar logs de Alfresco
echo "Capturando logs de catalina.out..."
if [ -f "$CATALINA_LOG_FILE" ]; then
    tail -n 500 "$CATALINA_LOG_FILE" > logs-$FECHA/alfresco/catalina.out
    echo "Guardado: logs-$FECHA/alfresco/catalina.out"
else
    echo "Advertencia: $CATALINA_LOG_FILE no encontrado."
fi

echo ""
# Capturar logs de Solr
echo "Capturando logs de solr.log..."
if [ -f "$SOLR_LOG_FILE" ]; then
    tail -n 500 "$SOLR_LOG_FILE" > logs-$FECHA/solr/solr.log
    echo "Guardado: logs-$FECHA/solr/solr.log"
else
    echo "Advertencia: $SOLR_LOG_FILE no encontrado."
fi

echo ""
# Capturar logs de todos los archivos de Transformation
echo "Capturando logs de Transformation..."
if [ -d "$TRANSFORM_SERVICE_LOG_DIR" ]; then
    for logfile in "$TRANSFORM_SERVICE_LOG_DIR"*.log; do
        if [ -f "$logfile" ]; then
            filename=$(basename "$logfile")
            tail -n 500 "$logfile" > logs-$FECHA/transformation/$filename
            echo "Guardado: logs-$FECHA/transformation/$filename"
        fi
    done
else
    echo "Advertencia: Directorio $TRANSFORM_SERVICE_LOG_DIR no encontrado."
fi

echo ""
# Capturar logs de activemq.log
echo "Capturando logs de activemq.log..."
if [ -f "$ACTIVEMQ_LOG_FILE" ]; then
    tail -n 500 "$ACTIVEMQ_LOG_FILE" > logs-$FECHA/activemq/activemq.log
    echo "Guardado: logs-$FECHA/activemq/activemq.log"
else
    echo "Advertencia: $ACTIVEMQ_LOG_FILE no encontrado."
fi

echo ""
# Capturar snapshot de recursos del sistema
echo "Capturando snapshot del sistema..."
{
    echo "========== TOP (primeras 30 líneas) =========="
    top -b -n 1 | head -n 30

    echo -e "\n========== FREE -h =========="
    free -h

    echo -e "\n========== DF -h =========="
    df -h

    echo -e "\n========== Procesos con mayor uso de MEMORIA =========="
    ps aux --sort=-%mem | head -n 10

    echo -e "\n========== Procesos con mayor uso de CPU =========="
    ps aux --sort=-%cpu | head -n 10
} > "$RECURSO_OUTPUT_FILE"
echo "Snapshot guardado en $RECURSO_OUTPUT_FILE"

echo ""
# Capturar estado de los servicios correctos
echo "Capturando estado de servicios..."
{
    systemctl status tomcat
    systemctl status solr
    systemctl status transformation
    systemctl status apachemq
} > "$SERVICES_STATUS_FILE"
echo "Estado de servicios guardado en $SERVICES_STATUS_FILE"

echo ""
# Capturar conexiones activas y uso de puertos
echo "Capturando conexiones activas y uso de puertos..."

if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    ss -tulnp > "$CONEXIONES_FILE"
else
    netstat -tulnp > "$CONEXIONES_FILE"
fi

echo "Conexiones guardadas en $CONEXIONES_FILE"

echo ""
# Capturar logs del sistema según distribución
echo "Copiando logs del sistema..."
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    cp /var/log/syslog logs-$FECHA/sistema/syslog.log 2>/dev/null
    cp /var/log/auth.log logs-$FECHA/sistema/auth.log 2>/dev/null
else
    cp /var/log/messages logs-$FECHA/sistema/messages.log 2>/dev/null
    cp /var/log/secure logs-$FECHA/sistema/secure.log 2>/dev/null
fi
cp /var/log/dmesg logs-$FECHA/sistema/dmesg.log 2>/dev/null

echo "Logs del sistema guardados en logs-$FECHA/sistema/"

echo ""
# Comprimir todo el directorio
echo "Comprimiendo archivos..."
tar -czvf logs-$FECHA.tar.gz logs-$FECHA
echo "Archivo comprimido: logs-$FECHA.tar.gz"

echo ""
echo "✅ Proceso completo de captura y empaquetado de logs finalizado."
