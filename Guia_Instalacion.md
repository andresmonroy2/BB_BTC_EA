# Guía de Instalación – BB_BTC_EA_v8_1


Esta guía te explicará cómo instalar y activar el Robot de Trading en tu plataforma MetaTrader 5.

---

## ¿Qué es BB_BTC_EA_v8_1?

Un **robot de trading automático** (Expert Advisor) que opera en **Bitcoin (BTCUSD)** basado en la estrategia de reversión a la media usando **Bandas de Bollinger**.

**Características principales:**
- Controla el riesgo automáticamente (arriesga % fijo por operación)
- Se protege contra pérdidas consecutivas (bloquea después de N pérdidas)
- Se protege contra sobreapalancamiento diario
- Funciona 24/7 (si está ejecutándose en tu equipo o VPS)

---

## Requisitos

### Hardware / Software
- **MetaTrader 5** (última versión disponible)
- Cuenta de trading (demo o real) con tu broker
- **Conexión estable a internet**
- Si operarás mientras tu computadora está apagada: contratar un **VPS** (recomendado)

### Requisitos de la Cuenta
- Apalancamiento: 1:100 mínimo (recomendado)
- Tipo de cuenta: **Netting** o **Hedging** (ambos soportados)
- Saldo mínimo: **$1,000 USD** (para demo/testing)

---

## Paso 1: Descargar el Robot

**Archivos que necesitas:**
- `BB_BTC_EA_v8_1.mq5`
- `default_parameters.set` (configuración recomendada)
- `Manual_Tecnico_Oficial.md` (documentación técnica)

---

## Paso 2: Instalar el Robot en MetaTrader 5

### 2.1 Abrir la carpeta de datos de MT5
1. Abre **MetaTrader 5**
2. En el menú superior: **Archivo** → **Abrir carpeta de datos**
3. Se abrirá una carpeta (ej: `C:\Users\TuNombre\AppData\Roaming\MetaQuotes\Terminal\...`)
4. Navega a: **MQL5** → **Experts**
   - Si no existe la carpeta `Experts`, créala

### 2.2 Copiar el archivo del robot
1. Copia el archivo `BB_BTC_EA_v8_1.mq5`
2. Pégalo en la carpeta **MQL5 → Experts**
3. Cierra la carpeta

### 2.3 Recargar MetaTrader
1. Vuelve a **MetaTrader 5**
2. En el panel izquierdo: haz clic en **Navigator** (si no lo ves, presiona `Ctrl+N`)
3. Expande **Expert Advisors**
4. Deberías ver `BB_BTC_EA_v8_1` en la lista

---

## Paso 3: Activar el Trading Algorítmico

Este paso es **OBLIGATORIO** o el robot no funcionará.

1. En MetaTrader: **Herramientas** → **Opciones**
2. Pestaña: **Asesores Expertos**
3. Marca ✓ las siguientes opciones:
   - ✓ **Permitir el trading automático**
   - ✓ **Permitir importar DLL de librerías** (si aparece)
   - ✓ **Permitir Web Request** (si aparece)
4. Click: **Aceptar**

**Nota:** Si no ves la opción de "trading automático", tu broker puede tener restricciones. Contacta con soporte del broker.

---

## Paso 4: Crear un Gráfico de Trading

El robot se activa en un gráfico específico.

### 4.1 Abre un gráfico de Bitcoin
1. Panel izquierdo en MetaTrader: **Catálogo de Mercados** (o presiona `Ctrl+M`)
2. Busca: `BTCUSD` (o `XBTCUSD`, depende de tu broker)
3. Haz doble clic para abrir el símbolo
4. Se abrirá un gráfico

### 4.2 Configura el marco temporal
1. En la barra superior del gráfico: selecciona **H1** (1 hora)
   - El robot está optimizado para operar en velas de **1 hora**
   - (Opcional: puedes usar D1 para operaciones diarias, pero H1 es recomendado)

---

## Paso 5: Cargar el Robot en el Gráfico

### 5.1 Arrastra el robot
1. En el panel **Navigator** (izquierda): busca **BB_BTC_EA_v8_1** bajo **Expert Advisors**
2. **Arrastra** el nombre del robot **hacia el gráfico**
3. Se abrirá automáticamente una ventana de **Configuración**

### 5.2 Configuración Recomendada (Parámetros)

Verás una lista de **parámetros**. Aquí está lo que significan:

| Parámetro | Valor Recomendado | Significado |
|-----------|-------------------|-------------|
| `RiskPercent` | `1.0` | Riesgo por operación (% de tu capital) |
| `BB_Period` | `20` | Período de las Bandas de Bollinger |
| `BB_Deviation` | `2.0` | Desviación estándar (volatilidad) |
| `StopLossPoints` | `1000` | Distancia del Stop Loss (en puntos) |
| `TakeProfitPoints` | `1500` | Distancia del Take Profit (ganancia objetivo) |
| `MaxSpreadPoints` | `300` | Máximo spread permitido (puntos) |
| `SlippagePoints` | `50` | Deslizamiento máximo tolerado |
| `MaxConsecutiveLosses` | `3` | Pérdidas consecutivas antes de bloquear |
| `MaxDailyDrawdownPercent` | `5.0` | Pérdida máxima diaria (%) |
| `MagicNumber` | `888888` | Identificador único del robot |

**Para comenzar (DEMO):** déjalos como están (valores por defecto).

### 5.3 Confirma los parámetros
1. Revisa que todo esté correcto
2. Click: **Aceptar**
3. El robot se cargará en el gráfico

---

## Paso 6: Verifica que el Robot está Activo

Después de hacer clic en **Aceptar**, deberías ver:

- Un **pequeño símbolo rojo/verde** en la esquina superior derecha del gráfico
  - **Verde**: Robot activo ✓
  - **Rojo**: Robot inactivo  (revisa errores)

- En el **panel de Journal** (abajo), deberías ver mensajes como:
  ```
  BB_BTC_EA_v8_1: Expert advisor started
  BB_BTC_EA_v8_1: Bollinger Bands initialized
  ```

- En **Posiciones Abiertas** (panel derecha): comenzará a mostrar operaciones cuando el robot entre en señales.

---

## Paso 7: Monitoreo Básico (Primeros días)

**Cada día, dedica 5 minutos a revisar:**

1. **Símbolo de estado:** ¿está verde? (robot activo)
2. **Panel de Journal:** ¿hay errores? (rojo = problema)
3. **Gráfico:** ¿aparecen operaciones? (órdenes abiertas/cerradas)
4. **Equidad:** ¿está en línea con lo esperado?

**Señales de que algo está mal:**
- Símbolo rojo en la esquina (robot bloqueado)
- Errores en el Journal (revisa el mensaje)
- Órdenes que cierran inmediatamente (problema de ejecución)

---

## Paso 8: Problemas Comunes

### Problema: "Expert advisor not allowed"
**Solución:**
- Ve a **Herramientas** → **Opciones**
- Pestaña **Asesores Expertos**
- Marca ✓ **Permitir el trading automático**

### Problema: El símbolo está en rojo (robot no corre)
**Soluciones:**
- Haz doble clic en el gráfico y el robot debería reactivarse
- Si persiste: elimina el robot y vuelve a cargarlo (Paso 5)

### Problema: No aparecen operaciones
**Posibles causas:**
- El spread está muy alto (> 300 puntos)
- No ha habido señal de trading aún (espera o cambia timeframe)
- El robot está bloqueado por protecciones (ej: máximo drawdown alcanzado)

**Revisa el Journal (Herramientas → Journal) para ver mensajes específicos.**

### Problema: "Insufficient margin"
**Solución:**
- Reduce el parámetro `RiskPercent` a 0.5
- O deposita más capital en la cuenta

---

## Paso 9: Apagar el Robot

### Opción 1: Detener globalmente (RECOMENDADO EN EMERGENCIAS)
1. En MetaTrader: **Herramientas** → **Opciones**
2. Pestaña **Asesores Expertos**
3. Desmarca ✗ **Permitir el trading automático**
4. **Las posiciones abiertas permanecen protegidas por Stop Loss en el servidor**

### Opción 2: Detener el robot en este gráfico
1. Haz clic derecho en el gráfico
2. **Asesores Expertos** → **Eliminar**
3. El robot se desactiva solo en ese gráfico

---

## Próximos Pasos

### Para Testing en DEMO (primeras 2-4 semanas)
1. ✓ Instalación completada
2. Monitorea operaciones diarias
3. Documenta resultados (ganancias/pérdidas)
4. Ajusta parámetros si es necesario
5. Cuando estés seguro → considera cuenta real pequeña

### Para Producción (cuenta real)
1. Realiza backtest en los últimos 2 años 
2. Forward test en demo mínimo 30 días
3. Comienza con `RiskPercent = 0.5%` (posiciones pequeñas)
4. Escala a 1.0% después de 2-4 semanas estables
5. Monitorea diariamente los primeros 30 días

---

## Referencia Rápida de Comandos

| Necesito... | Cómo hacerlo |
|-------------|------------|
| Abrir el Journal | **Herramientas** → **Journal** (o `Ctrl+J`) |
| Ver Posiciones abiertas | Panel derecha: **Posiciones** |
| Ver Historial de operaciones | Panel derecha: **Historial** |
| Cambiar parámetros | Click derecho gráfico → **Asesores Expertos** → **Editar entrada** |
| Recargar el robot | Click derecho → **Asesores Expertos** → **Eliminar**, luego recarga |
| Emergencia (apagar todo) | **Herramientas** → **Opciones** → Desmarca **Trading automático** |

---

## Contacto & Soporte

- **Documentación completa:** revisa `Manual_Tecnico_Oficial.md`

---

**Última actualización:** 18 de mayo de 2026  
**Versión:** 1.0  
**Estado:** Listo para usar
