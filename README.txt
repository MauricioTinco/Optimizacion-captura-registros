# 📄 Captura de Logs y Snapshot del Servidor Alfresco - Script Universal

## 📦 Descripción General
Este repositorio contiene un **script automatizado y adaptable** para capturar logs críticos y el estado del sistema en servidores que ejecutan Alfresco.  
El script detecta automáticamente si el servidor corre en **Ubuntu/Debian** o **CentOS/Red Hat** y ejecuta los comandos adecuados según la distribución.

---

## 🖥️ Características
- ✅ Detección automática del sistema operativo.
- ✅ Captura de logs críticos de:
  - Alfresco (Tomcat)
  - Solr
  - Alfresco Transformation Service
  - ActiveMQ
- ✅ Captura de snapshot del sistema:
  - Uso de CPU, memoria y disco
  - Procesos activos
  - Puertos abiertos y conexiones
- ✅ Copia de logs del sistema según la distribución:
  - Ubuntu/Debian: `syslog`, `auth.log`
  - CentOS/Red Hat: `messages`, `secure`
- ✅ Comprime todos los resultados en un archivo `.tar.gz` para facilitar la gestión.

---

## 📂 Estructura de Carpetas Generadas
Cada ejecución crea una carpeta con la fecha actual, por ejemplo:
logs-YYYY-MM-DD/
├── activemq/
├── alfresco/
├── solr/
├── transformation/
├── recurso/ # Snapshot de comandos del sistema
├── sistema/ # Logs del sistema y estado de servicios
└── logs-YYYY-MM-DD.tar.gz # Archivo comprimido
---

## ⚙️ Pasos para la Ejecución

### 1. Clona el repositorio
git clone https://github.com/MauricioTinco/Optimizacion-captura-registros.git
cd <carpeta-del-repositorio>
###2. Da permisos de ejecución al script
chmod +x snapshot.sh
###3. Ejecuta el script con permisos de superusuario
sudo ./snapshot.sh
###4. Verifica la salida generada
Una vez finalizado, se creará un archivo comprimido:
logs-YYYY-MM-DD.tar.gz
Este archivo contiene todos los logs y snapshots organizados por carpetas.
