# 🎯 COMANDOS SÚPER SIMPLES - CHORD DHT

## 📋 Un solo archivo para todo: `chord.sh`

### 🚀 Uso Básico (comandos de 1 línea)

```bash
# 1. Compilar proyecto
./chord.sh build

# 2. Configurar VMs
./chord.sh setup bootstrap    # En VM Europa
./chord.sh setup joiner       # En VM Sudamérica/US

# 3. Operaciones básicas
./chord.sh put test "Hola mundo"
./chord.sh get test
./chord.sh locate test

# 4. Tests y simulación
./chord.sh test               # Test completo
./chord.sh simulate 50        # Simular 50 nodos
./chord.sh benchmark          # Medir rendimiento

# 5. Monitoreo
./chord.sh status             # Ver estado
./chord.sh logs               # Ver logs
./chord.sh metrics            # Ver métricas
```

## 🌍 Setup Completo en 3 VMs (súper fácil)

### VM1 - Europa (Bootstrap)
```bash
git clone https://github.com/ivettmera/DS-DHT-chord.git
cd DS-DHT-chord
chmod +x chord.sh

./chord.sh build
./chord.sh setup bootstrap
```

### VM2 - Sudamérica
```bash
git clone https://github.com/ivettmera/DS-DHT-chord.git
cd DS-DHT-chord
chmod +x chord.sh

./chord.sh build
./chord.sh setup joiner
```

### VM3 - US Central
```bash
git clone https://github.com/ivettmera/DS-DHT-chord.git
cd DS-DHT-chord
chmod +x chord.sh

./chord.sh build
./chord.sh setup joiner
```

## 🧪 Pruebas Intercontinentales

### Test básico (desde cualquier VM)
```bash
# Insertar datos
./chord.sh put global_test "Ring funcionando en 3 continentes!"

# Leer desde diferentes VMs (automático)
./chord.sh get global_test

# Localizar dónde está el dato
./chord.sh locate global_test

# Test completo automatizado
./chord.sh test
```

### Simulación masiva
```bash
# En VM1 (Europa)
./chord.sh simulate 50

# En VM2 (Sudamérica)  
./chord.sh simulate 50

# En VM3 (US Central)
./chord.sh simulate 50

# Total: 153 nodos distribuidos globalmente
```

## 📊 Monitoreo Simple

```bash
# Ver todo el estado
./chord.sh status

# Ver logs en tiempo real
./chord.sh logs

# Ver métricas generadas
./chord.sh metrics

# Benchmark de rendimiento
./chord.sh benchmark
```

## 🛠️ Control del Sistema

```bash
# Detener todo
./chord.sh stop

# Limpiar datos
./chord.sh clean

# Ver ayuda completa
./chord.sh help
```

## ✅ Validación Rápida

```bash
# 1. Verificar que todo compila
./chord.sh build

# 2. Verificar estado del ring
./chord.sh status

# 3. Test básico de conectividad
./chord.sh put validation "Sistema funcionando"
./chord.sh get validation

# 4. Test de rendimiento
./chord.sh benchmark
```

## 🎯 Comandos para Demostración

### Escenario 1: Datos distribuidos globalmente
```bash
./chord.sh put europa "Datos desde Europa"
./chord.sh put sudamerica "Datos desde Sudamérica"  
./chord.sh put usa "Datos desde Estados Unidos"

# Leer desde cualquier VM
./chord.sh get europa
./chord.sh get sudamerica
./chord.sh get usa
```

### Escenario 2: Tolerancia a fallos
```bash
# En VM1: insertar datos
./chord.sh put fault_test "Datos importantes"

# Detener VM1
./chord.sh stop

# En VM2: datos siguen disponibles
./chord.sh get fault_test
```

### Escenario 3: Escalabilidad masiva
```bash
# Ejecutar en las 3 VMs simultáneamente
./chord.sh simulate 50

# Ver métricas combinadas
./chord.sh metrics
```

## 🚨 Troubleshooting

```bash
# Si algo falla
./chord.sh stop
./chord.sh clean
./chord.sh build
./chord.sh setup [bootstrap|joiner]

# Ver logs de errores
./chord.sh logs | grep -i error

# Verificar conectividad
./chord.sh status
```

---

**🎉 ¡Con un solo script tienes control total del Ring DHT global!**

El archivo `chord.sh` simplifica todo el proceso. Solo necesitas recordar:
- `./chord.sh build` (compilar)
- `./chord.sh setup bootstrap/joiner` (configurar)
- `./chord.sh put/get/locate` (usar)
- `./chord.sh test/simulate` (probar)
- `./chord.sh status/logs` (monitorear)