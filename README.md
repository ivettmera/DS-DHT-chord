# Chord DHT - Distributed Hash Table

Un proyecto de sistemas distribuidos que implementa el protocolo Chord DHT con soporte para múltiples VMs de Google Cloud, métricas de rendimiento y simulación de escalabilidad.

##  Estructura del Proyecto

```
chord/
  docs/                          # Documentación completa
    DEPLOYMENT_GUIDE.md          # Guía de despliegue Google Cloud
    MODIFICATIONS_SUMMARY.md     # Historial de cambios
    PROJECT_STRUCTURE.md         # Estructura detallada
    *.md                         # Documentación adicional

  cmd/                          # Aplicaciones ejecutables
    simulator/                   # Simulador multi-nodo
        main.go

   server/                       # Aplicación servidor
    main.go                      # Nodo del ring Chord
    config.yaml                  # Configuración
    chord                        # Binario (auto-generado)

  client/                       # Aplicación cliente
    main.go                      # Cliente GET/PUT/LOCATE
    config.yaml                  # Configuración
    chord                        # Binario (auto-generado)

  chordpb/                      # Protocol Buffers
    chord.proto                  # Definiciones gRPC
    chord.pb.go                  # Código generado

   scripts/                      # Scripts organizados
    automation/                  # Demostración y experimentos
    build/                       # Construcción del proyecto
    deployment/                  # Despliegue en Google Cloud
    README.md                    # Documentación de scripts

  tools/                        # Herramientas de desarrollo
    analyze_results.py           # Análisis de métricas
    gen-pb.sh                    # Generador Protocol Buffers
    README.md                    # Documentación de herramientas

  examples/                     # Ejemplos y casos de uso
    test-nodes/                  # Nodos de ejemplo (.example)
    README.md                    # Documentación de ejemplos

  bin/                          # Binarios compilados
    chord-server                 # Servidor principal
    chord-client                 # Cliente de operaciones
    chord-simulator              # Simulador de escalabilidad
    .gitkeep                     # Mantener directorio en git

  *.go (raíz)                   # Código fuente principal
     node.go                      # Implementación nodo Chord
     rpc.go                       # Servicios gRPC
     config.go                    # Sistema de configuración
     finger.go                    # Tabla de dedos
     replica.go                   # Sistema de replicación
     util.go                      # Utilidades generales
     metrics.go                   # Sistema de métricas
     *_test.go                    # Tests unitarios
```

##  VMs de Google Cloud Configuradas

- **ds-node-1 (Bootstrap)**: `34.38.96.126` - Europa (europe-west1-d) 🇪🇺
- **ds-node-2**: `35.199.69.216` - Sudamérica (southamerica-east1-c) 🇧🇷
- **us-central1-c**: `34.58.253.117` - US Central (us-central1-c) 🇺🇸 

##  Inicio Rápido

### Compilación
```bash
# Opción 1: Script automatizado
./scripts/build/build.sh

# Opción 2: Manual
go build -o bin/chord-server ./server
go build -o bin/chord-client ./client
go build -o bin/chord-simulator ./cmd/simulator
```

### Uso Local
```bash
# 1. Iniciar nodo bootstrap
./bin/chord-server create --addr 0.0.0.0 --port 8000

# 2. Unir segundo nodo (nueva terminal)
./bin/chord-server join localhost 8000 --addr 0.0.0.0 --port 8001

# 3. Operaciones básicas
echo "Hello World" | ./bin/chord-client put localhost:8000 mykey
./bin/chord-client get localhost:8001 mykey
./bin/chord-client locate localhost:8000 mykey
```

### 🐧 Despliegue Linux VMs (3 Continentes)
```bash
# 1. Setup automatizado en cada VM
chmod +x scripts/deployment/setup-linux-vm.sh

# VM1 Europa (Bootstrap)
./scripts/deployment/setup-linux-vm.sh bootstrap

# VM2 Sudamérica + VM3 US Central  
./scripts/deployment/setup-linux-vm.sh joiner

# 2. Probar ring global
chmod +x scripts/automation/test-global-ring.sh
./scripts/automation/test-global-ring.sh
```

**📋 Guía completa Linux:** [LINUX_SETUP_GUIDE.md](LINUX_SETUP_GUIDE.md)

### Simulación y Experimentos
```bash
# Simulador básico (20 nodos, 5 minutos)
./bin/chord-simulator -nodes 20 -duration 300s -output metrics/

# Demostración automatizada
./scripts/automation/demo.sh

# Experimentos de escalabilidad
./scripts/automation/run-experiments.sh
```

##  Sistema de Métricas

### Datos Recolectados
- **Latencia**: Tiempo promedio de lookups (ms)
- **Throughput**: Mensajes por segundo
- **Escalabilidad**: Nodos activos por timestamp
- **Distribución**: Métricas por región geográfica

### Formato CSV
```csv
timestamp,nodes,messages,lookups,avg_lookup_ms
2024-11-20T10:00:00Z,3,150,45,12.5
2024-11-20T10:00:10Z,3,165,52,11.8
```

### Análisis
```bash
# Generar gráficos y estadísticas
python3 tools/analyze_results.py metrics_directory/
```

##  Documentación

- **[docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md)** - Guía completa Google Cloud
- **[docs/MODIFICATIONS_SUMMARY.md](docs/MODIFICATIONS_SUMMARY.md)** - Historial de cambios
- **[scripts/README.md](scripts/README.md)** - Scripts disponibles
- **[tools/README.md](tools/README.md)** - Herramientas de desarrollo
- **[examples/README.md](examples/README.md)** - Ejemplos de uso

##  Características Implementadas

-  **Protocolo Chord completo** - Ring formation, finger tables, stabilization
-  **Multi-VM support** - Conexiones cross-region via IPs externas  
-  **Sistema de métricas** - Recolección automática en CSV
-  **Simulador de escalabilidad** - Hasta 150+ nodos distribuidos
-  **Replicación de datos** - Tolerancia a fallos con replica groups
-  **Cliente gRPC completo** - Operaciones GET/PUT/LOCATE
-  **Configuración flexible** - YAML y flags CLI
-  **Scripts de automatización** - Deploy y experimentos automatizados
-  **Herramientas de análisis** - Generación de gráficos y estadísticas

##  Testing

```bash
# Tests unitarios
go test -v

# Test de conectividad (requiere nodos activos)
./bin/chord-client get localhost:8000 test_key

# Simulación de carga
./bin/chord-simulator -nodes 50 -duration 600s -output test_results/
```

##  Experimentos Disponibles

1. **Ring Local**: 2-10 nodos en una máquina
2. **Multi-VM**: 3 VMs físicas + 50 nodos simulados c/u (153 total)
3. **Cross-Region**: Latencia Europa  US con métricas detalladas
4. **Fault Tolerance**: Desconexión de nodos y recuperación automática
5. **Escalabilidad**: Crecimiento incremental hasta 200+ nodos

##  Desarrollo

### Estructura Modular
- **Código fuente principal** en raíz (estándar Go)
- **Aplicaciones** en directorios específicos
- **Scripts** organizados por función
- **Documentación** centralizada
- **Herramientas** separadas del código core

### Extensibilidad
- Fácil agregar nuevos tipos de nodos
- Sistema de métricas extensible  
- Scripts reutilizables para diferentes clouds
- Configuración flexible por archivo o CLI

---
**MC714 - Sistemas Distribuidos | UNICAMP | 2024**
