# Protocolo de Forward Testing – BB_BTC_EA_v8_3

## Guía para Testear el Robot en Cuenta Demo (30 días)

---

## ¿Qué es Forward Testing?

Es el proceso de **probar el robot en condiciones reales de mercado** (pero sin dinero real) durante un período de tiempo definido.

**Objetivo:** verificar que el robot funciona como se espera en un entorno similar al que usarás en producción.

**Duración recomendada:** 30 días mínimo (4 semanas)

---

## Fase 0: Preparación Inicial

### 0.1 Abre una Cuenta Demo
1. En MetaTrader 5: **Archivo** → **Abrir cuenta nueva**
2. Selecciona **Cuenta de demostración**
3. Elige tu broker
4. Configura:
   - **Nombre de cuenta:** `BB_BTC_EA_DEMO_TEST` (identifica fácilmente)
   - **Servidor:** (el mismo que usarás en real)
   - **Apalancamiento:** 1:100 (estándar)
   - **Saldo inicial:** $10,000 USD (cantidad realista)
   - **Zona horaria:** tu zona local

### 0.2 Instala el Robot
Sigue la **Guía de Instalación** (pasos 1-6) para cargar el robot en un gráfico **BTCUSD** con timeframe **H1**.

### 0.3 Parámetros para Testing en Demo
Usa estos parámetros **conservadores** (reducir riesgo durante testing):

```
RiskPercent              = 0.5     (no 1.0) - pequeñas posiciones
BB_Period                = 20      (mantén default)
BB_Deviation             = 2.0     (mantén default)
StopLossPoints           = 1000    (mantén default)
TakeProfitPoints         = 1500    (mantén default)
MaxRetriesPerBar         = 3       (mantén default)
MaxSpreadPoints          = 300     (monitorea spreads reales)
SlippagePoints           = 50      (ajusta si hay re-quotes frecuentes)
MaxConsecutiveLosses     = 3       (mantén default)
MaxDailyDrawdownPercent  = 5.0     (mantén default)
MagicNumber              = 888888  (mantén default)
```

**Razón:** con 0.5% de riesgo en $10,000, cada operación arriesga ~$50. Esto permite ver el comportamiento sin pérdidas enormes.

---

## Fase 1: Semana 1 (Días 1-7)

### Objetivo
Verificar que el robot **funciona sin errores** en condiciones de mercado reales.

### Checklist Diario (5 minutos cada mañana)

- [ ] **¿El robot está activo?**
  - Mira el símbolo en la esquina del gráfico: ¿está verde?
  - Si está rojo, anota la hora y el error en el Journal

- [ ] **¿Hay nuevas operaciones?**
  - Abre el panel **Historial** (derecha)
  - Cuenta cuántas operaciones se abrieron/cerraron ayer
  - ¿Es razonable? (esperamos 1-3 operaciones por día en H1 con Bitcoin)

- [ ] **¿El equity creció o bajó?**
  - Panel **Posiciones**: mira el **Equity** actual vs. ayer
  - Anota: fecha, equity, número de operaciones

- [ ] **¿Hay errores en el Journal?**
  - Abre **Herramientas** → **Journal**
  - ¿Hay mensajes rojo = error? Anótalos
  - Errores comunes permitidos: "Requote detectado" (es normal)

### Tabla de Monitoreo (Semana 1)

Copia esta tabla en un archivo Excel o papel:

```
Fecha       Equity($)  Cambio($)  # Ops  Estado   Notas
---         ------     -----      -----  -------  -----
Día 1       10000      0          0      ✓ OK     Robot cargado
Día 2       9995       -5         1      ✓ OK     1 pérdida pequeña
Día 3       10050      +55        2      ✓ OK     1 ganancia, 1 pérdida
...
```

### Decisión al Final de Semana 1

**Continúa si:**
- ✓ Robot está verde (funcionando)
- ✓ No hay crashes o errores críticos
- ✓ Hay operaciones (señales detectadas)
- ✓ El equity es estable (sin caídas anormales > 5%)

**DETÉN el test si:**
- ✗ Robot está rojo permanentemente
- ✗ Hay errores que se repiten (`Insufficient margin`, `Invalid price`, etc.)
- ✗ Equity bajó > 20% en 1 semana
- ✗ No hay operaciones después de 3 días (posible problema de broker/conexión)

---

## Fase 2: Semana 2-3 (Días 8-21)

### Objetivo
Evaluar la **rentabilidad y estabilidad** del robot a mediano plazo.

### Checklist Diario (incluso detalles)

**Sigue el checklist de Semana 1, PLUS:**

- [ ] **Spread en BTCUSD**
  - Mira el bid-ask del gráfico
  - Typical: 5-20 puntos en crypto
  - Si > 300 puntos: el robot no entra (protección activada)
  - Anota spreads anómalos

- [ ] **Horario de operaciones**
  - ¿A qué horas el robot abre posiciones?
  - (debería ser durante volatilidad, típicamente 0:00-8:00 UTC)

- [ ] **Duración de operaciones**
  - ¿Cuánto tarda en cerrarse cada trade?
  - Típicamente: 1-24 horas con este robot

### Tabla Expandida (Semanas 2-3)

```
Fecha       Equity   Cambio  # Ops  Spread  Mayor Ganancia/Pérdida  Estado
---         ------   ------  -----  ------  ----------------------  ------
Día 8       10200    +200    5      15pts   +150 (ganancia)         ✓ OK
Día 9       10150    -50     2      20pts   -100 (pérdida)          ✓ OK
...
```

### Análisis al Final de Semana 3

Calcula:
- **Profit Factor** = (Ganancias Totales) / (Pérdidas Totales)
  - Ej: si ganó $1000 y perdió $400 → PF = 2.5 ✓ (bueno)
  - Meta: PF > 1.4

- **Drawdown máximo** = (Equity mínimo - Equity inicial) / Equity inicial × 100%
  - Ej: si bajó a $9500 desde $10000 → DD = 5% ✓ (aceptable)
  - Meta: DD < 25%

- **Win Rate** = (# operaciones ganadoras) / (# operaciones totales) × 100%
  - Ej: 7 ganadoras de 15 total → WR = 47% 
  - Meta: > 40%

---

## Fase 3: Semana 4 (Días 22-30)

### Objetivo
**Confirmación final** — asegurar que el robot se comporta consistentemente.

### Checklist Diario (mismo que Semana 2-3)

- Registra los mismos datos
- Busca anomalías (cambios bruscos en comportamiento)

### Análisis Final de 30 Días

**Tabla Resumen:**

```
MÉTRICAS FINALES (30 DÍAS)
==========================
Equity Inicial:          $10,000
Equity Final:            $10,XXX
Ganancia Neta:           $XXX
Profit Factor:           X.X
Drawdown Máximo:         X.X%
Número de Operaciones:   XXX
Win Rate:                XX%
Días Operados:           XXX
Operaciones/Día:         X.X

DECISIÓN FINAL
==============
[ ] APROBADO - Pasar a cuenta real pequeña
[ ] RECHAZADO - Revisar parámetros
[ ] INCONCLUSO - Extender 15 días más
```

---

## Criterios de Aprobación

El robot está **LISTO para cuenta real pequeña** si:

✓ **Técnico:**
- No hay crashes o errores críticos
- El robot funciona 24/7 sin intervención manual
- Spread y slippage se mantienen dentro de límites

✓ **Comercial:**
- Profit Factor ≥ 1.4
- Drawdown máximo ≤ 25%
- Win Rate ≥ 40%
- Equity curve estable (sin caídas anormales)

✓ **Psicológico (importante):**
- **Confías en el robot** — entiendes por qué entra/sale
- Esperas bien las pérdidas (serán normales)
- No sientes miedo de "arruinarse" (porque riskyPercent es bajo)

---

## Criterios de Rechazo

**DETÉN el test y revisa parámetros si:**

✗ Profit Factor < 1.2
✗ Drawdown > 40%
✗ Win Rate < 30%
✗ Robot bloqueado frecuentemente (protecciones activadas)
✗ Spread promedio > MaxSpreadPoints (300 puntos)
✗ El robot tarda días sin abrir operaciones

**Acciones:**
1. Contacta a Andrés (ingeniero)
2. Revisen los parámetros juntos
3. Hagan un backtest en los últimos 5 años
4. Ajusten y reinicien 30-días de forward test

---

## Próximos Pasos Después de Aprobación

Si el robot fue **APROBADO**:

### 1. Cuenta Real Pequeña (Semanas 1-4)
- Crea una cuenta real con **$1,000 USD** (o tu mínimo)
- Parámetros: `RiskPercent = 0.5%` (IGUAL que demo)
- Monitorea diariamente
- Si todo va bien después de 4 semanas, escalamos

### 2. Escalada Gradual (Después de Semana 4)
- **Semana 5-8:** `RiskPercent = 0.75%`
- **Semana 9+:** `RiskPercent = 1.0%` (producción)

### 3. Vigilancia Permanente
- Monitorea el robot cada día
- Registra equity semanalmente
- En caso de anomalía: DETÉN inmediatamente

---

## Plantilla Excel para Descargar

Crea un archivo Excel con estas columnas:

```
A: Fecha
B: Hora Inicio
C: Equity Inicial
D: Equity Final
E: Cambio ($)
F: # Operaciones
G: Ganancia Mayor
H: Pérdida Mayor
I: Spread Promedio
J: Notas / Observaciones
K: Estado (✓ OK / ✗ ERROR)
```

Usa **gráficos** para visualizar la evolución de equity.

---

## Contacto Durante Forward Test

Si algo va mal:

1. **Anota el error exacto** (del Journal)
2. **Captura pantalla** del gráfico y del error
3. **Contacta a Andrés**
4. **NO HAGAS CAMBIOS manualmente** — espera confirmación

---

## Checklist Final (Leer antes de comenzar)

- [ ] Leí esta guía completa
- [ ] Tengo una cuenta demo lista
- [ ] El robot está cargado y verde
- [ ] Empiezo HOY con 30 días de forward test
- [ ] Prepararé mi tabla de monitoreo (Excel o papel)
- [ ] Revisaré diariamente (5 minutos)
- [ ] Contactaré a Andrés si hay problemas

---

**Última actualización:** 18 de mayo de 2026  
**Versión:** 1.0  
**Autor:** Andrés (Ingeniero de Sistemas)
