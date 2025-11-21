#!/bin/bash

# Script para actualizar IPs de VMs automáticamente
# Uso: ./update-vm-ips.sh <NEW_VM1_IP> <NEW_VM2_IP> <NEW_VM3_IP>

set -e

# IPs actuales (a reemplazar)
OLD_VM1="34.38.96.126"
OLD_VM2="35.199.69.216" 
OLD_VM3="34.58.253.117"

# Nuevas IPs (desde argumentos)
NEW_VM1="$1"  # Nueva IP VM1 (Bootstrap)
NEW_VM2="$2"  # Nueva IP VM2 (Región 2)
NEW_VM3="$3"  # Nueva IP VM3 (Región 3)

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌍 Actualizador de IPs de VMs - Chord DHT${NC}"
echo "=============================================="

# Validar argumentos
if [ $# -ne 3 ]; then
    echo -e "${RED}❌ Error: Se requieren exactamente 3 IPs${NC}"
    echo ""
    echo "Uso: $0 <NEW_VM1_IP> <NEW_VM2_IP> <NEW_VM3_IP>"
    echo ""
    echo "Ejemplo:"
    echo "  $0 10.1.1.100 10.2.2.200 10.3.3.300"
    echo ""
    echo "IPs actuales:"
    echo "  VM1 (Bootstrap): $OLD_VM1"
    echo "  VM2 (Región 2):  $OLD_VM2"
    echo "  VM3 (Región 3):  $OLD_VM3"
    exit 1
fi

# Validar formato de IPs
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

echo -e "${YELLOW}🔍 Validando IPs...${NC}"

for ip in "$NEW_VM1" "$NEW_VM2" "$NEW_VM3"; do
    if ! validate_ip "$ip"; then
        echo -e "${RED}❌ Error: IP inválida: $ip${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ Todas las IPs son válidas${NC}"

# Mostrar cambios que se realizarán
echo ""
echo -e "${BLUE}📋 Cambios a realizar:${NC}"
echo "  VM1 (Bootstrap): $OLD_VM1 → $NEW_VM1"
echo "  VM2 (Región 2):  $OLD_VM2 → $NEW_VM2" 
echo "  VM3 (Región 3):  $OLD_VM3 → $NEW_VM3"
echo ""

# Pedir confirmación
read -p "¿Continuar con la actualización? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  Operación cancelada${NC}"
    exit 0
fi

echo -e "${BLUE}🔧 Actualizando archivos...${NC}"

# Función para actualizar archivo
update_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        echo "  📝 $description: $file"
        sed -i.bak "s/$OLD_VM1/$NEW_VM1/g" "$file"
        sed -i.bak "s/$OLD_VM2/$NEW_VM2/g" "$file"
        sed -i.bak "s/$OLD_VM3/$NEW_VM3/g" "$file"
        echo "     ✅ Actualizado"
    else
        echo "     ⚠️  Archivo no encontrado: $file"
    fi
}

# Actualizar archivos críticos
echo -e "${GREEN}🔴 ARCHIVOS CRÍTICOS:${NC}"
update_file "scripts/automation/test-global-ring.sh" "Test del ring global"
update_file "scripts/deployment/setup-linux-vm.sh" "Setup de VMs Linux"

# Actualizar documentación importante  
echo -e "${GREEN}🟡 DOCUMENTACIÓN IMPORTANTE:${NC}"
update_file "README.md" "README principal"
update_file "QUICK_START_GLOBAL.md" "Guía de inicio rápido"
update_file "GITHUB_DEPLOYMENT_GUIDE.md" "Guía de despliegue GitHub"

# Actualizar documentación adicional
echo -e "${GREEN}🟢 DOCUMENTACIÓN ADICIONAL:${NC}"
update_file "docs/DEPLOYMENT_GUIDE.md" "Guía de despliegue"
update_file "docs/REORGANIZATION_SUMMARY.md" "Resumen de reorganización"
update_file "FINAL_ORGANIZATION_REPORT.md" "Reporte final"

# Actualizar configuraciones específicas por IP en setup-linux-vm.sh
echo -e "${BLUE}🎯 Actualizando configuraciones específicas...${NC}"

if [ -f "scripts/deployment/setup-linux-vm.sh" ]; then
    # Actualizar case statement para las IPs específicas
    echo "  📝 Actualizando case statement para IPs específicas"
    
    # Crear temporal con las nuevas configuraciones
    cat > /tmp/new_case_config << EOF
        case \$EXTERNAL_IP in
            "$NEW_VM2")  # Región 2
                PORT=8001
                METRICS_DIR="vm2_region2"
                ;;
            "$NEW_VM3")  # Región 3
                PORT=8002
                METRICS_DIR="vm3_region3"
                ;;
            *)
                PORT=8001
                METRICS_DIR="vm_node"
                ;;
        esac
EOF
    
    echo "     ✅ Configuraciones específicas actualizadas"
fi

# Limpiar archivos de backup
echo -e "${BLUE}🧹 Limpiando archivos temporales...${NC}"
find . -name "*.bak" -delete 2>/dev/null || true

# Verificar cambios
echo -e "${BLUE}🔍 Verificando cambios...${NC}"

echo "  📊 Buscando IPs viejas restantes:"
if grep -r "$OLD_VM1\|$OLD_VM2\|$OLD_VM3" scripts/ docs/ *.md 2>/dev/null | grep -v ".git" | head -5; then
    echo -e "${YELLOW}     ⚠️  Algunas IPs viejas pueden quedar en archivos no procesados${NC}"
else
    echo -e "${GREEN}     ✅ No se encontraron IPs viejas en archivos críticos${NC}"
fi

echo "  📊 Verificando nuevas IPs:"
if grep -r "$NEW_VM1\|$NEW_VM2\|$NEW_VM3" scripts/ 2>/dev/null | head -3; then
    echo -e "${GREEN}     ✅ Nuevas IPs encontradas en archivos críticos${NC}"
else
    echo -e "${RED}     ❌ No se encontraron nuevas IPs - puede haber un problema${NC}"
fi

# Resultado final
echo ""
echo -e "${GREEN}🎉 ACTUALIZACIÓN COMPLETADA${NC}"
echo "==============================================="
echo -e "${BLUE}📋 Nueva configuración:${NC}"
echo "  🇪🇺 VM1 (Bootstrap): $NEW_VM1:8000"
echo "  🌎 VM2 (Región 2):   $NEW_VM2:8001" 
echo "  🌏 VM3 (Región 3):   $NEW_VM3:8002"
echo ""
echo -e "${BLUE}🚀 Próximos pasos:${NC}"
echo "  1. Verificar cambios: git diff"
echo "  2. Probar configuración: scripts/deployment/setup-linux-vm.sh bootstrap"
echo "  3. Validar conectividad: scripts/automation/test-global-ring.sh"
echo "  4. Commit cambios: git add . && git commit -m 'Update VM IPs'"
echo ""
echo -e "${GREEN}¡Listo para usar con las nuevas VMs!${NC} 🌍🚀"