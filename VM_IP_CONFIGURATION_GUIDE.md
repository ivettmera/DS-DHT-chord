# 🌍 GUÍA DE CONFIGURACIÓN DE VMS Y REGIONES

## 📋 **ARCHIVOS A EDITAR PARA CAMBIAR IPs Y REGIONES**

### **🎯 ARCHIVOS CRÍTICOS (Obligatorios)**

#### **1. `/scripts/automation/test-global-ring.sh`**
```bash
# IPs de las VMs
VM1_IP="34.38.96.126"    # Europa (Bootstrap) 
VM2_IP="35.199.69.216"   # Sudamérica  
VM3_IP="34.58.253.117"   # US Central
```

#### **2. `/scripts/deployment/setup-linux-vm.sh`**
```bash
BOOTSTRAP_IP="34.38.96.126"

# Y en la función join_ring():
case $EXTERNAL_IP in
    "35.199.69.216")  # Sudamérica
        PORT=8001
        METRICS_DIR="vm2_southamerica"
        ;;
    "34.58.253.117")  # US Central
        PORT=8002
        METRICS_DIR="vm3_uscentral"
        ;;
```

---

### **📚 ARCHIVOS DE DOCUMENTACIÓN (Recomendados)**

#### **3. `README.md`**
```yaml
- **ds-node-1 (Bootstrap)**: `34.38.96.126` - Europa (europe-west1-d) 🇪🇺
- **ds-node-2**: `35.199.69.216` - Sudamérica (southamerica-east1-c) 🇧🇷
- **us-central1-c**: `34.58.253.117` - US Central (us-central1-c) 🇺🇸
```

#### **4. `QUICK_START_GLOBAL.md`**
```yaml
- **ds-node-1**: `34.38.96.126` - 🇪🇺 Europa (europe-west1-d) 
- **ds-node-2**: `35.199.69.216` - 🇧🇷 Sudamérica (southamerica-east1-c)
- **us-central1-c**: `34.58.253.117` - 🇺🇸 US Central (us-central1-c)
```

#### **5. `GITHUB_DEPLOYMENT_GUIDE.md`**
```yaml
- ds-node-1: Europe (34.38.96.126)
- ds-node-2: South America (35.199.69.216)  
- us-central1-c: US Central (34.58.253.117)
```

#### **6. `docs/DEPLOYMENT_GUIDE.md`**
```yaml
- **ds-node-1 (Bootstrap)**: `34.38.96.126` - Europa (europe-west1-d) 🇪🇺
- **ds-node-2**: `35.199.69.216` - Sudamérica (southamerica-east1-c) 🇧🇷  
- **us-central1-c**: `34.58.253.117` - US Central (us-central1-c) 🇺🇸
```

---

## 🛠️ **PASOS PARA CAMBIAR VMs/REGIONES**

### **Paso 1: Obtener Nuevas IPs**
```bash
# Obtener IP externa de cada nueva VM
gcloud compute instances describe NOMBRE_VM --zone=ZONA --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

### **Paso 2: Editar Archivos Críticos**
```bash
# 1. Actualizar IPs en test-global-ring.sh
vim scripts/automation/test-global-ring.sh

# 2. Actualizar IP bootstrap en setup-linux-vm.sh  
vim scripts/deployment/setup-linux-vm.sh
```

### **Paso 3: Actualizar Documentación (Opcional)**
```bash
# Buscar y reemplazar todas las IPs viejas
grep -r "34.38.96.126" . --exclude-dir=.git | cut -d: -f1 | sort -u
grep -r "35.199.69.216" . --exclude-dir=.git | cut -d: -f1 | sort -u  
grep -r "34.58.253.117" . --exclude-dir=.git | cut -d: -f1 | sort -u
```

---

## 🌍 **CONFIGURACIONES PARA NUEVAS REGIONES**

### **Ejemplo: Agregar Asia-Pacific**

#### **Nuevas VMs:**
```yaml
VM1_IP="34.38.96.126"     # Europa (Bootstrap)
VM2_IP="35.199.69.216"    # Sudamérica  
VM3_IP="34.58.253.117"    # US Central
VM4_IP="35.247.XXX.XXX"   # Asia-Pacific (NUEVA)
```

#### **Editar `setup-linux-vm.sh`:**
```bash
case $EXTERNAL_IP in
    "35.199.69.216")  # Sudamérica
        PORT=8001
        METRICS_DIR="vm2_southamerica"
        ;;
    "34.58.253.117")  # US Central
        PORT=8002
        METRICS_DIR="vm3_uscentral"
        ;;
    "35.247.XXX.XXX")  # Asia-Pacific (NUEVO)
        PORT=8003
        METRICS_DIR="vm4_asiapacific"
        ;;
```

#### **Editar `test-global-ring.sh`:**
```bash
VM1_IP="34.38.96.126"    # Europa (Bootstrap)
VM2_IP="35.199.69.216"   # Sudamérica  
VM3_IP="34.58.253.117"   # US Central
VM4_IP="35.247.XXX.XXX"  # Asia-Pacific (NUEVO)
```

---

## 🚀 **SCRIPT DE ACTUALIZACIÓN AUTOMÁTICA**

### **Crear `update-vm-ips.sh`:**
```bash
#!/bin/bash

# Script para actualizar IPs de VMs automáticamente
OLD_VM1="34.38.96.126"
OLD_VM2="35.199.69.216" 
OLD_VM3="34.58.253.117"

NEW_VM1="$1"  # Nueva IP VM1
NEW_VM2="$2"  # Nueva IP VM2
NEW_VM3="$3"  # Nueva IP VM3

if [ $# -ne 3 ]; then
    echo "Uso: $0 <NEW_VM1_IP> <NEW_VM2_IP> <NEW_VM3_IP>"
    exit 1
fi

echo "Actualizando IPs de VMs..."

# Actualizar archivos críticos
sed -i "s/$OLD_VM1/$NEW_VM1/g" scripts/automation/test-global-ring.sh
sed -i "s/$OLD_VM2/$NEW_VM2/g" scripts/automation/test-global-ring.sh  
sed -i "s/$OLD_VM3/$NEW_VM3/g" scripts/automation/test-global-ring.sh

sed -i "s/$OLD_VM1/$NEW_VM1/g" scripts/deployment/setup-linux-vm.sh
sed -i "s/$OLD_VM2/$NEW_VM2/g" scripts/deployment/setup-linux-vm.sh
sed -i "s/$OLD_VM3/$NEW_VM3/g" scripts/deployment/setup-linux-vm.sh

# Actualizar documentación
sed -i "s/$OLD_VM1/$NEW_VM1/g" README.md QUICK_START_GLOBAL.md
sed -i "s/$OLD_VM2/$NEW_VM2/g" README.md QUICK_START_GLOBAL.md
sed -i "s/$OLD_VM3/$NEW_VM3/g" README.md QUICK_START_GLOBAL.md

echo "✅ IPs actualizadas exitosamente!"
echo "Nueva configuración:"
echo "  VM1 (Bootstrap): $NEW_VM1"
echo "  VM2 (Región 2):  $NEW_VM2" 
echo "  VM3 (Región 3):  $NEW_VM3"
```

---

## 📊 **RESUMEN DE PRIORIDADES**

### **🔴 CRÍTICO (Debe editarse):**
1. `scripts/automation/test-global-ring.sh`
2. `scripts/deployment/setup-linux-vm.sh`

### **🟡 IMPORTANTE (Recomendado):**
3. `README.md`
4. `QUICK_START_GLOBAL.md`
5. `GITHUB_DEPLOYMENT_GUIDE.md`

### **🟢 OPCIONAL (Documentación):**
6. `docs/DEPLOYMENT_GUIDE.md`
7. `docs/REORGANIZATION_SUMMARY.md`
8. `FINAL_ORGANIZATION_REPORT.md`

---

## 🎯 **VALIDACIÓN POST-CAMBIO**

```bash
# 1. Verificar que no hay IPs viejas
grep -r "34.38.96.126\|35.199.69.216\|34.58.253.117" scripts/

# 2. Probar configuración
scripts/deployment/setup-linux-vm.sh bootstrap

# 3. Validar conectividad
scripts/automation/test-global-ring.sh
```

**¡Con estos cambios tu proyecto funcionará con cualquier conjunto de VMs y regiones!** 🌍🚀