#!/bin/bash

# Script para configurar VM Linux para Chord DHT
# Uso: ./setup-linux-vm.sh [vm-role]
# Roles: bootstrap, joiner

set -e

VM_ROLE=${1:-"joiner"}
BOOTSTRAP_IP="34.38.96.126"

echo "=== Configurando VM Linux para Chord DHT ==="
echo "Rol: $VM_ROLE"

# Detectar IP externa
EXTERNAL_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip)
echo "IP Externa detectada: $EXTERNAL_IP"

# Crear directorios necesarios
mkdir -p results/metrics results/logs bin

# Función para compilar proyecto
compile_project() {
    echo "Compilando proyecto..."
    export PATH=$PATH:/usr/local/go/bin
    
    go mod tidy
    go build -o bin/chord-server ./server
    go build -o bin/chord-client ./client
    go build -o bin/chord-simulator ./cmd/simulator
    
    echo "Compilación completada:"
    ls -la bin/
}

# Función para iniciar nodo bootstrap
start_bootstrap() {
    echo "Iniciando nodo bootstrap en $EXTERNAL_IP:8000"
    
    mkdir -p results/metrics/vm1_bootstrap results/logs
    
    nohup ./bin/chord-server create \
        --addr 0.0.0.0 \
        --port 8000 \
        --metrics \
        --metrics-dir results/metrics/vm1_bootstrap \
        --log-level info \
        > results/logs/vm1_bootstrap.log 2>&1 &
    
    echo "Bootstrap iniciado. PID: $!"
    echo "Ver logs: tail -f results/logs/vm1_bootstrap.log"
    
    # Esperar que inicie
    sleep 5
    
    # Verificar que está corriendo
    if ps aux | grep -q "[c]hord-server"; then
        echo "✅ Bootstrap corriendo exitosamente"
        echo "Dirección: $EXTERNAL_IP:8000"
    else
        echo "❌ Error: Bootstrap no se inició correctamente"
        cat results/logs/vm1_bootstrap.log
        exit 1
    fi
}

# Función para unirse al ring
join_ring() {
    echo "Uniéndose al ring bootstrap en $BOOTSTRAP_IP:8000"
    
    # Determinar puerto basado en IP
    case $EXTERNAL_IP in
        "35.199.69.216")  # Sudamérica
            PORT=8001
            METRICS_DIR="vm2_southamerica"
            ;;
        "34.58.253.117")  # US Central
            PORT=8002
            METRICS_DIR="vm3_uscentral"
            ;;
        *)
            PORT=8001
            METRICS_DIR="vm_node"
            ;;
    esac
    
    echo "Puerto asignado: $PORT"
    mkdir -p results/metrics/$METRICS_DIR results/logs
    
    # Verificar que bootstrap esté disponible
    echo "Verificando bootstrap..."
    if ! timeout 10 bash -c "echo >/dev/tcp/$BOOTSTRAP_IP/8000"; then
        echo "❌ Error: No se puede conectar al bootstrap $BOOTSTRAP_IP:8000"
        echo "Asegúrate de que el nodo bootstrap esté corriendo"
        exit 1
    fi
    
    echo "✅ Bootstrap disponible"
    
    # Unirse al ring
    nohup ./bin/chord-server join $BOOTSTRAP_IP 8000 \
        --addr 0.0.0.0 \
        --port $PORT \
        --metrics \
        --metrics-dir results/metrics/$METRICS_DIR \
        --log-level info \
        > results/logs/${METRICS_DIR}.log 2>&1 &
    
    echo "Nodo unido al ring. PID: $!"
    echo "Ver logs: tail -f results/logs/${METRICS_DIR}.log"
    
    # Esperar que se conecte
    sleep 10
    
    # Verificar que está corriendo
    if ps aux | grep -q "[c]hord-server"; then
        echo "✅ Nodo corriendo exitosamente"
        echo "Dirección: $EXTERNAL_IP:$PORT"
    else
        echo "❌ Error: Nodo no se inició correctamente"
        cat results/logs/${METRICS_DIR}.log
        exit 1
    fi
}

# Función para mostrar estado
show_status() {
    echo ""
    echo "=== Estado del Sistema ==="
    echo "Procesos Chord:"
    ps aux | grep chord || echo "No hay procesos chord corriendo"
    
    echo ""
    echo "Puertos abiertos:"
    ss -tulpn | grep :800 || echo "No hay puertos 8000+ abiertos"
    
    echo ""
    echo "Logs recientes:"
    if [ -d "results/logs" ]; then
        find results/logs -name "*.log" -exec echo "=== {} ===" \; -exec tail -3 {} \;
    fi
}

# Función principal
main() {
    # Verificar que Go esté instalado
    if ! command -v go &> /dev/null; then
        echo "❌ Error: Go no está instalado"
        echo "Instala Go con:"
        echo "wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz"
        echo "sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz"
        echo "echo 'export PATH=\$PATH:/usr/local/go/bin' >> ~/.bashrc"
        echo "source ~/.bashrc"
        exit 1
    fi
    
    echo "Go version: $(go version)"
    
    # Compilar proyecto
    compile_project
    
    # Configurar firewall
    echo "Configurando firewall..."
    sudo ufw allow 8000:8010/tcp 2>/dev/null || echo "Firewall ya configurado o no disponible"
    
    # Ejecutar según rol
    case $VM_ROLE in
        "bootstrap")
            start_bootstrap
            ;;
        "joiner")
            join_ring
            ;;
        *)
            echo "Rol inválido: $VM_ROLE"
            echo "Uso: $0 [bootstrap|joiner]"
            exit 1
            ;;
    esac
    
    # Mostrar estado final
    show_status
    
    echo ""
    echo "=== Configuración Completada ==="
    echo "VM configurada como: $VM_ROLE"
    echo "IP: $EXTERNAL_IP"
    echo ""
    echo "Comandos útiles:"
    echo "- Ver logs: tail -f results/logs/*.log"
    echo "- Ver procesos: ps aux | grep chord"
    echo "- Detener: pkill -f chord-server"
    echo "- Probar: ./bin/chord-client put $EXTERNAL_IP:8000 test 'hello world'"
}

# Ejecutar función principal
main "$@"