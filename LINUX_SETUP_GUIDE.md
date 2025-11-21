# 🚀 SETUP CHORD DHT - LINUX VMs

## 📋 Pre-requisitos en cada VM Linux

### 1. Configuración inicial en cada VM
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install -y git wget curl build-essential

# Instalar Go 1.21
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Verificar Go
go version
```

### 2. Clonar y compilar proyecto
```bash
# Clonar tu repositorio
git clone https://github.com/ivettmera/DS-DHT-chord.git
cd DS-DHT-chord

# Crear directorios necesarios
mkdir -p results/metrics results/logs bin

# Compilar
go mod tidy
go build -o bin/chord-server ./server
go build -o bin/chord-client ./client
go build -o bin/chord-simulator ./cmd/simulator

# Verificar compilación
ls -la bin/
```

## 🌍 Despliegue en 3 VMs

### VM1: ds-node-1 (Europa - Bootstrap)
```bash
# IP: 34.38.96.126
# Crear directorios
mkdir -p results/metrics/vm1_bootstrap results/logs

# Iniciar nodo bootstrap
nohup ./bin/chord-server create \
    --addr 0.0.0.0 \
    --port 8000 \
    --metrics \
    --metrics-dir results/metrics/vm1_bootstrap \
    --log-level info \
    > results/logs/vm1_bootstrap.log 2>&1 &

# Verificar que está corriendo
ps aux | grep chord-server
tail -f results/logs/vm1_bootstrap.log
```

### VM2: ds-node-2 (Sudamérica)
```bash
# IP: 35.199.69.216
# Esperar 30 segundos después del bootstrap
sleep 30

# Crear directorios
mkdir -p results/metrics/vm2_southamerica results/logs

# Unirse al ring
nohup ./bin/chord-server join 34.38.96.126 8000 \
    --addr 0.0.0.0 \
    --port 8001 \
    --metrics \
    --metrics-dir results/metrics/vm2_southamerica \
    --log-level info \
    > results/logs/vm2_southamerica.log 2>&1 &

# Verificar conexión
ps aux | grep chord-server
tail -f results/logs/vm2_southamerica.log
```

### VM3: us-central1-c (US Central)
```bash
# IP: 34.58.253.117
# Esperar 30 segundos después de VM2
sleep 30

# Crear directorios
mkdir -p results/metrics/vm3_uscentral results/logs

# Unirse al ring  
nohup ./bin/chord-server join 34.38.96.126 8000 \
    --addr 0.0.0.0 \
    --port 8002 \
    --metrics \
    --metrics-dir results/metrics/vm3_uscentral \
    --log-level info \
    > results/logs/vm3_uscentral.log 2>&1 &

# Verificar conexión
ps aux | grep chord-server  
tail -f results/logs/vm3_uscentral.log
```

## 🧪 Pruebas del Ring Global

### Test básico intercontinental
```bash
# Desde cualquier VM, probar comunicación global

# PUT desde Europa
./bin/chord-client put 34.38.96.126:8000 test_global "Hola desde 3 continentes!"

# GET desde Sudamérica
./bin/chord-client get 35.199.69.216:8001 test_global

# GET desde US Central
./bin/chord-client get 34.58.253.117:8002 test_global

# LOCATE desde cualquier VM
./bin/chord-client locate 34.38.96.126:8000 test_global
```

### Test de latencia cross-regional
```bash
# Script para medir latencias
for i in {1..5}; do
    echo "=== Test $i ==="
    echo "Europa:"
    time ./bin/chord-client get 34.38.96.126:8000 test_global
    echo "Sudamérica:"  
    time ./bin/chord-client get 35.199.69.216:8001 test_global
    echo "US Central:"
    time ./bin/chord-client get 34.58.253.117:8002 test_global
    echo "---"
done
```

## 📊 Monitoreo y Control

### Ver estado del ring
```bash
# Procesos activos
ps aux | grep chord

# Conexiones de red
ss -tulpn | grep :800

# Logs en tiempo real
tail -f results/logs/*.log

# Métricas generadas
ls -la results/metrics/*/
```

### Detener nodos
```bash
# Detener todos los nodos chord
pkill -f chord-server

# Verificar que se detuvieron
ps aux | grep chord
```

### Reiniciar nodo específico
```bash
# Ejemplo: reiniciar VM2
pkill -f chord-server
sleep 5

# Volver a unirse
nohup ./bin/chord-server join 34.38.96.126 8000 \
    --addr 0.0.0.0 \
    --port 8001 \
    --metrics \
    --metrics-dir results/metrics/vm2_southamerica \
    --log-level info \
    > results/logs/vm2_southamerica.log 2>&1 &
```

## 🎯 Simulación de Escalabilidad

### Ejecutar simuladores en paralelo
```bash
# En VM1 (Europa): 50+ nodos virtuales
nohup ./bin/chord-simulator \
    -nodes 50 \
    -bootstrap-addr 34.38.96.126 \
    -bootstrap-port 8000 \
    -duration 300s \
    -output results/metrics/simulation_europa/ \
    > results/logs/simulator_europa.log 2>&1 &

# En VM2 (Sudamérica): 50+ nodos virtuales  
nohup ./bin/chord-simulator \
    -nodes 50 \
    -bootstrap-addr 34.38.96.126 \
    -bootstrap-port 8000 \
    -duration 300s \
    -output results/metrics/simulation_southamerica/ \
    > results/logs/simulator_southamerica.log 2>&1 &

# En VM3 (US): 50+ nodos virtuales
nohup ./bin/chord-simulator \
    -nodes 50 \
    -bootstrap-addr 34.38.96.126 \
    -bootstrap-port 8000 \
    -duration 300s \
    -output results/metrics/simulation_us/ \
    > results/logs/simulator_us.log 2>&1 &
```

### Análisis de resultados
```bash
# Recolectar métricas de todas las VMs
python3 tools/analyze_results.py \
    results/metrics/simulation_europa/ \
    results/metrics/simulation_southamerica/ \
    results/metrics/simulation_us/

# Ver resumen
cat results/global_metrics_summary.csv
```

## 🚨 Troubleshooting

### Problemas comunes
```bash
# Si falla la conexión entre VMs
sudo ufw allow 8000:8010/tcp
sudo ufw reload

# Si no encuentra Go
export PATH=$PATH:/usr/local/go/bin
source ~/.bashrc

# Si hay puertos ocupados
sudo netstat -tulpn | grep :8000
sudo kill -9 <PID>
```

### Verificar conectividad entre VMs
```bash
# Desde cualquier VM, probar conectividad
ping -c 3 34.38.96.126  # Europa
ping -c 3 35.199.69.216  # Sudamérica  
ping -c 3 34.58.253.117  # US Central

# Probar puertos
telnet 34.38.96.126 8000
telnet 35.199.69.216 8001
telnet 34.58.253.117 8002
```

## ✅ Checklist de Validación

- [ ] Go 1.21+ instalado en todas las VMs
- [ ] Proyecto clonado y compilado en cada VM
- [ ] Firewall configurado (puertos 8000-8010)
- [ ] VM1 corriendo como bootstrap
- [ ] VM2 y VM3 unidos al ring exitosamente
- [ ] Pruebas PUT/GET funcionando entre VMs
- [ ] Logs generándose correctamente
- [ ] Métricas siendo recolectadas

**¡Ring DHT distribuido en 3 continentes funcionando!** 🌍🚀