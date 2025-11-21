#!/bin/bash

# Script principal para controlar el proyecto Chord DHT
# Uso: ./chord.sh <comando> [opciones]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar help
show_help() {
    echo -e "${BLUE}🚀 Chord DHT - Sistema de Control Simplificado${NC}"
    echo ""
    echo "COMANDOS PRINCIPALES:"
    echo ""
    echo -e "${GREEN}Setup y Compilación:${NC}"
    echo "  ./chord.sh build                    # Compilar todos los binarios"
    echo "  ./chord.sh setup bootstrap          # Configurar VM como bootstrap (Europa)"
    echo "  ./chord.sh setup joiner             # Configurar VM como joiner (SA/US)"
    echo ""
    echo -e "${GREEN}Control de Nodos:${NC}"
    echo "  ./chord.sh start bootstrap          # Iniciar nodo bootstrap"
    echo "  ./chord.sh start joiner             # Unirse al ring"
    echo "  ./chord.sh stop                     # Detener todos los nodos"
    echo "  ./chord.sh status                   # Ver estado del ring"
    echo ""
    echo -e "${GREEN}Operaciones del Ring:${NC}"
    echo "  ./chord.sh put <key> <value>        # Insertar datos"
    echo "  ./chord.sh get <key>                # Obtener datos"
    echo "  ./chord.sh locate <key>             # Localizar clave"
    echo ""
    echo -e "${GREEN}Testing y Simulación:${NC}"
    echo "  ./chord.sh test                     # Ejecutar tests completos"
    echo "  ./chord.sh simulate <nodes>         # Simular N nodos"
    echo "  ./chord.sh benchmark                # Benchmark de rendimiento"
    echo ""
    echo -e "${GREEN}Utilidades:${NC}"
    echo "  ./chord.sh logs                     # Ver todos los logs"
    echo "  ./chord.sh metrics                  # Mostrar métricas"
    echo "  ./chord.sh clean                    # Limpiar logs y métricas"
    echo ""
    echo -e "${YELLOW}Ejemplos:${NC}"
    echo "  ./chord.sh build"
    echo "  ./chord.sh setup bootstrap          # En VM Europa"
    echo "  ./chord.sh setup joiner             # En VM Sudamérica/US"
    echo "  ./chord.sh put test 'Hola mundo'"
    echo "  ./chord.sh get test"
    echo "  ./chord.sh simulate 50"
}

# Función para compilar
build_project() {
    echo -e "${BLUE}🔨 Compilando proyecto...${NC}"
    
    # Verificar Go
    if ! command -v go &> /dev/null; then
        echo -e "${RED}❌ Error: Go no está instalado${NC}"
        exit 1
    fi
    
    echo "Go version: $(go version)"
    
    # Crear directorios
    mkdir -p bin results/logs results/metrics
    
    # Compilar
    echo "Compilando servidor..."
    go build -o bin/chord-server ./server
    
    echo "Compilando cliente..."
    go build -o bin/chord-client ./client
    
    echo "Compilando simulador..."
    go build -o bin/chord-simulator ./cmd/simulator
    
    echo -e "${GREEN}✅ Compilación completada${NC}"
    ls -la bin/
}

# Función para setup
setup_vm() {
    local role=$1
    if [ -z "$role" ]; then
        echo -e "${RED}❌ Error: Especifica rol: bootstrap o joiner${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🔧 Configurando VM como $role...${NC}"
    
    # Hacer ejecutable y ejecutar script
    chmod +x scripts/deployment/setup-linux-vm.sh
    ./scripts/deployment/setup-linux-vm.sh "$role"
}

# Función para iniciar nodos
start_node() {
    local role=$1
    if [ -z "$role" ]; then
        echo -e "${RED}❌ Error: Especifica tipo: bootstrap o joiner${NC}"
        exit 1
    fi
    
    case $role in
        "bootstrap")
            echo -e "${BLUE}🚀 Iniciando nodo bootstrap...${NC}"
            mkdir -p results/metrics/bootstrap results/logs
            
            nohup ./bin/chord-server create \
                --addr 0.0.0.0 \
                --port 8000 \
                --metrics \
                --metrics-dir results/metrics/bootstrap \
                --log-level info \
                > results/logs/bootstrap.log 2>&1 &
            
            echo -e "${GREEN}✅ Bootstrap iniciado (PID: $!)${NC}"
            echo "Logs: tail -f results/logs/bootstrap.log"
            ;;
            
        "joiner")
            echo -e "${BLUE}🔗 Uniéndose al ring...${NC}"
            
            # Detectar IP y puerto
            EXTERNAL_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip)
            case $EXTERNAL_IP in
                "35.199.69.216") PORT=8001; REGION="southamerica" ;;
                "34.58.253.117") PORT=8002; REGION="uscentral" ;;
                *) PORT=8001; REGION="node" ;;
            esac
            
            mkdir -p results/metrics/$REGION results/logs
            
            nohup ./bin/chord-server join 34.38.96.126 8000 \
                --addr 0.0.0.0 \
                --port $PORT \
                --metrics \
                --metrics-dir results/metrics/$REGION \
                --log-level info \
                > results/logs/$REGION.log 2>&1 &
            
            echo -e "${GREEN}✅ Nodo unido al ring (PID: $!)${NC}"
            echo "Puerto: $PORT, Región: $REGION"
            echo "Logs: tail -f results/logs/$REGION.log"
            ;;
            
        *)
            echo -e "${RED}❌ Rol inválido: $role${NC}"
            exit 1
            ;;
    esac
}

# Función para detener nodos
stop_nodes() {
    echo -e "${YELLOW}🛑 Deteniendo todos los nodos...${NC}"
    
    pkill -f chord-server || echo "No hay procesos chord-server corriendo"
    pkill -f chord-simulator || echo "No hay simuladores corriendo"
    
    sleep 2
    
    if ps aux | grep -q "[c]hord-server\|[c]hord-simulator"; then
        echo -e "${YELLOW}⚠️  Algunos procesos siguen corriendo, forzando...${NC}"
        pkill -9 -f chord-server
        pkill -9 -f chord-simulator
    fi
    
    echo -e "${GREEN}✅ Todos los nodos detenidos${NC}"
}

# Función para ver estado
show_status() {
    echo -e "${BLUE}📊 Estado del Ring DHT${NC}"
    echo ""
    
    echo "Procesos activos:"
    ps aux | grep chord | grep -v grep || echo "No hay procesos chord corriendo"
    
    echo ""
    echo "Puertos abiertos:"
    ss -tulpn | grep :800 || echo "No hay puertos 8000+ abiertos"
    
    echo ""
    echo "Conectividad VMs:"
    for ip in "34.38.96.126" "35.199.69.216" "34.58.253.117"; do
        if timeout 3 bash -c "echo >/dev/tcp/$ip/8000" 2>/dev/null; then
            echo -e "${GREEN}✅ $ip:8000 - Accesible${NC}"
        else
            echo -e "${RED}❌ $ip:8000 - No accesible${NC}"
        fi
    done
}

# Función para operaciones del ring
ring_put() {
    local key=$1
    local value=$2
    if [ -z "$key" ] || [ -z "$value" ]; then
        echo -e "${RED}❌ Error: ./chord.sh put <key> <value>${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📝 PUT: $key = $value${NC}"
    ./bin/chord-client put 34.38.96.126:8000 "$key" "$value"
}

ring_get() {
    local key=$1
    if [ -z "$key" ]; then
        echo -e "${RED}❌ Error: ./chord.sh get <key>${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📖 GET: $key${NC}"
    ./bin/chord-client get 34.38.96.126:8000 "$key"
}

ring_locate() {
    local key=$1
    if [ -z "$key" ]; then
        echo -e "${RED}❌ Error: ./chord.sh locate <key>${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🔍 LOCATE: $key${NC}"
    ./bin/chord-client locate 34.38.96.126:8000 "$key"
}

# Función para ejecutar tests
run_tests() {
    echo -e "${BLUE}🧪 Ejecutando tests del ring global...${NC}"
    chmod +x scripts/automation/test-global-ring.sh
    ./scripts/automation/test-global-ring.sh
}

# Función para simular
run_simulation() {
    local nodes=${1:-50}
    echo -e "${BLUE}🎮 Simulando ring con $nodes nodos...${NC}"
    
    mkdir -p results/metrics/simulation results/logs
    
    nohup ./bin/chord-simulator \
        -nodes "$nodes" \
        -bootstrap-addr 34.38.96.126 \
        -bootstrap-port 8000 \
        -duration 300s \
        -output results/metrics/simulation/ \
        > results/logs/simulation.log 2>&1 &
    
    echo -e "${GREEN}✅ Simulación iniciada (PID: $!)${NC}"
    echo "Nodos: $nodes, Duración: 5 minutos"
    echo "Ver progreso: tail -f results/logs/simulation.log"
}

# Función para mostrar logs
show_logs() {
    echo -e "${BLUE}📋 Logs del sistema${NC}"
    
    if [ -d "results/logs" ]; then
        find results/logs -name "*.log" -exec echo -e "\n${YELLOW}=== {} ===${NC}" \; -exec tail -10 {} \;
    else
        echo "No hay logs disponibles"
    fi
}

# Función para mostrar métricas
show_metrics() {
    echo -e "${BLUE}📊 Métricas del sistema${NC}"
    
    if [ -d "results/metrics" ]; then
        find results/metrics -name "*.csv" -exec echo -e "\n${YELLOW}=== {} ===${NC}" \; -exec wc -l {} \;
        
        echo -e "\n${BLUE}Últimas métricas:${NC}"
        find results/metrics -name "*.csv" -exec tail -5 {} \; 2>/dev/null
    else
        echo "No hay métricas disponibles"
    fi
}

# Función para limpiar
clean_data() {
    echo -e "${YELLOW}🧹 Limpiando logs y métricas...${NC}"
    
    rm -rf results/logs/* results/metrics/*
    mkdir -p results/logs results/metrics
    
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

# Función para benchmark
run_benchmark() {
    echo -e "${BLUE}⚡ Ejecutando benchmark de rendimiento...${NC}"
    
    # Test de throughput
    echo "Test de throughput (100 operaciones)..."
    start_time=$(date +%s)
    
    for i in {1..100}; do
        ./bin/chord-client put 34.38.96.126:8000 "bench_$i" "value_$i" >/dev/null 2>&1
    done
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    throughput=$((100 / duration))
    
    echo -e "${GREEN}✅ Throughput: $throughput ops/sec${NC}"
    
    # Test de latencia
    echo "Test de latencia (10 mediciones)..."
    total_time=0
    
    for i in {1..10}; do
        start_ms=$(date +%s%3N)
        ./bin/chord-client get 34.38.96.126:8000 "bench_1" >/dev/null 2>&1
        end_ms=$(date +%s%3N)
        latency=$((end_ms - start_ms))
        total_time=$((total_time + latency))
        echo "Latencia $i: ${latency}ms"
    done
    
    avg_latency=$((total_time / 10))
    echo -e "${GREEN}✅ Latencia promedio: ${avg_latency}ms${NC}"
}

# Función principal
main() {
    case $1 in
        "build")
            build_project
            ;;
        "setup")
            setup_vm "$2"
            ;;
        "start")
            start_node "$2"
            ;;
        "stop")
            stop_nodes
            ;;
        "status")
            show_status
            ;;
        "put")
            ring_put "$2" "$3"
            ;;
        "get")
            ring_get "$2"
            ;;
        "locate")
            ring_locate "$2"
            ;;
        "test")
            run_tests
            ;;
        "simulate")
            run_simulation "$2"
            ;;
        "benchmark")
            run_benchmark
            ;;
        "logs")
            show_logs
            ;;
        "metrics")
            show_metrics
            ;;
        "clean")
            clean_data
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo -e "${RED}❌ Comando desconocido: $1${NC}"
            echo "Usa: ./chord.sh help"
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"