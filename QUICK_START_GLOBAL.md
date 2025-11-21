# 🚀 GUÍA RÁPIDA CHORD DHT - 3 CONTINENTES

## 🌍 VMs Configuradas (Distribución Global)
- **ds-node-1**: `34.38.96.126` - 🇪🇺 Europa (europe-west1-d) 
- **ds-node-2**: `35.199.69.216` - 🇧🇷 Sudamérica (southamerica-east1-c)
- **us-central1-c**: `34.58.253.117` - 🇺🇸 US Central (us-central1-c)

## ⚡ Setup Rápido (5 minutos)

### 1️⃣ Compilar (en cada VM Linux)
```bash
# Hacer ejecutable
chmod +x scripts/build/build.sh

# Compilar
./scripts/build/build.sh
```

### 2️⃣ Desplegar VMs (en orden)

**ds-node-1 (Europa - Bootstrap):**
```bash
# Ejecutar como daemon en background
nohup ./bin/chord-server create --addr 0.0.0.0 --port 8000 --metrics \
  --metrics-dir results/metrics/vm1_bootstrap \
  --log-level info > results/logs/vm1_bootstrap.log 2>&1 &

# Verificar que está corriendo
ps aux | grep chord-server
```

**Esperar 30 segundos** ⏳

**ds-node-2 (Sudamérica):**
```bash
# Crear directorios
mkdir -p results/metrics/vm2_southamerica results/logs

# Unirse al ring
nohup ./bin/chord-server join 34.38.96.126 8000 --addr 0.0.0.0 --port 8001 \
  --metrics --metrics-dir results/metrics/vm2_southamerica \
  --log-level info > results/logs/vm2_southamerica.log 2>&1 &
```

**Esperar 30 segundos** ⏳

**us-central1-c (US Central):**
```bash
# Crear directorios
mkdir -p results/metrics/vm3_uscentral results/logs

# Unirse al ring
nohup ./bin/chord-server join 34.38.96.126 8000 --addr 0.0.0.0 --port 8002 \
  --metrics --metrics-dir results/metrics/vm3_uscentral \
  --log-level info > results/logs/vm3_uscentral.log 2>&1 &
```

## 🧪 Pruebas Rápidas

### Test Básico Intercontinental
```bash
# Europa → Sudamérica → US
echo "Hola 3 continentes!" | ./bin/chord-client put 34.38.96.126:8000 global_test

# Leer desde Sudamérica
./bin/chord-client get 35.199.69.216:8000 global_test

# Leer desde US
./bin/chord-client get 34.58.253.117:8000 global_test

# Localizar desde cualquier VM
./bin/chord-client locate 34.38.96.126:8000 global_test
```

### Test de Latencia Cross-Region
```bash
# Medir latencias entre continentes
for i in {1..5}; do
  echo "=== Test $i ==="
  time ./bin/chord-client get 34.38.96.126:8000 global_test  # Europa
  time ./bin/chord-client get 35.199.69.216:8000 global_test # Sudamérica  
  time ./bin/chord-client get 34.58.253.117:8000 global_test # US
done
```

## 📊 Experimentos de Escalabilidad

### Simuladores en Paralelo (153 nodos totales)
```bash
# En ds-node-1 (Europa): 50 nodos
./bin/chord-simulator -nodes 50 -bootstrap-addr 34.38.96.126 -bootstrap-port 8000 -duration 600s -output metrics_europa/

# En ds-node-2 (Sudamérica): 50 nodos  
./bin/chord-simulator -nodes 50 -bootstrap-addr 34.38.96.126 -bootstrap-port 8000 -duration 600s -output metrics_sudamerica/

# En us-central1-c (US): 50 nodos
./bin/chord-simulator -nodes 50 -bootstrap-addr 34.38.96.126 -bootstrap-port 8000 -duration 600s -output metrics_us/
```

### Análisis Global
```bash
# Recolectar métricas de todas las VMs
python3 tools/analyze_results.py metrics_europa/ metrics_sudamerica/ metrics_us/
```

## 🔧 Comandos de Control

### Ver Estado
```bash
# Procesos activos
ps aux | grep chord

# Conexiones de red
ss -tlnp | grep :8000
```

### Detener Todo
```bash
# Detener nodos
pkill -f chord-server

# Detener simuladores
pkill -f chord-simulator
```

## 📈 Métricas Esperadas

Con esta configuración tendrás:
- **Latencia Europa ↔ Sudamérica**: ~200-300ms
- **Latencia Europa ↔ US**: ~150-200ms  
- **Latencia Sudamérica ↔ US**: ~150-250ms
- **Throughput total**: 150+ nodos distribuidos
- **Cobertura global**: 3 continentes, 3 regiones

## 🎯 Casos de Uso para Demostración

1. **Tolerancia Global**: Desconectar Europa, ring sigue en Sudamérica+US
2. **Distribución de Carga**: Datos se replican automáticamente  
3. **Escalabilidad**: De 3 a 153 nodos sin reconfiguración
4. **Latencia Real**: Medición de delays intercontinentales
5. **Consistencia**: Mismo dato accesible desde cualquier continente

**¡Ring DHT global funcionando en 3 continentes!** 🌍🚀