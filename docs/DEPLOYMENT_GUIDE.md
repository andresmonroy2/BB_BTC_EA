# Guía de Implementación y Despliegue

## Visión General

Este documento establece los pasos y consideraciones para desplegar el BB_BTC_EA en:
1. **Ambiente Demo** (validación)
2. **Ambiente Real** (producción escalada)

---

## Pre-Requisitos de Infraestructura

### Broker
- Cuenta MetaTrader 5 (demo o real)
- Símbolo BTCUSD disponible
- Acceso a históricos ≥ 24 meses
- Confirmación de comisiones y spread

### Hardware
- **Windows** (para MetaEditor + MT5)
- **Conexión estable**: Latencia < 500ms
- **VPS recomendado**: Para trading 24/5 sin interrupciones
  - CPU: 2+ cores
  - RAM: 2+ GB
  - Uptime: 99.5%+

### Software
- MetaTrader 5 (última versión estable)
- .NET Framework (requerido por MT5)

---

## Fase 1: Instalación Demo

### Paso 1: Preparación de Archivos

```
Descargar:
├── BB_BTC_EA_v8_1.mq5          (fuente EA)
├── default_parameters.set      (configuración)
└── Manual_Tecnico_Oficial.md   (referencia)
```

### Paso 2: Compilación en MetaEditor

1. Abre MetaTrader 5
2. Tools → MetaEditor
3. File → Open → selecciona `BB_BTC_EA_v8_1.mq5`
4. F7 o Compile
   - ✓ Sin errores
   - ⚠ Warnings aceptables

**Resultado esperado**: `BB_BTC_EA_v8_1.ex5` generado en `MQL5/Experts/`

### Paso 3: Carga en Gráfica

1. MT5 → Navegador → Expertos
2. Doble-clic `BB_BTC_EA_v8_1`
3. Inputs → Importar `default_parameters.set`
4. Algoritmo Trading: **ACTIVADO** ✓
5. Vivir Trading: **DESACTIVADO** (demo solo)

### Paso 4: Validación Inicial

- [ ] EA aparece en gráfica
- [ ] Status muestra versión (v8.1)
- [ ] Entrada a trade genera órdenes
- [ ] Cierre de trade genera cierre

**Demo completo**: Ejecuta 7-30 días en demo

---

## Fase 2: Backtesting Completo

Ver: `BACKTEST_VALIDATION_PROTOCOL.md`

**Objetivos**:
- Profit Factor ≥ 1.4
- Drawdown ≤ 25%
- Win Rate ≥ 40%
- 24+ meses de datos validados

---

## Fase 3: Forward Testing (30 días)

Ver: `Protocolo_Forward_Testing.md` (usuario final)

**Objetivos**:
- Validación en datos nuevos (no vistos en backtest)
- Confirmación de comportamiento en vivo
- Calibración de parámetros si es necesario

---

## Fase 4: Implementación Real - Escalado

### Escalado Recomendado

```
Semana 1: RiskPercent = 0.5%   (50% de producción)
Semana 2-3: RiskPercent = 0.75% (75% de producción)
Semana 4+: RiskPercent = 1.0%  (100% - producción nominal)
```

### Paso 1: Cambio a Cuenta Real

1. Crear nueva gráfica en símbolo real
2. Configurar parámetros iniciales (0.5% risk)
3. Validar:
   - [ ] Conexión a broker real
   - [ ] Comisiones reales aplicadas
   - [ ] Spread real en símbolos
   - [ ] Margen disponible suficiente

### Paso 2: Activación Gradual

**Día 1-7 (0.5% risk)**
- Monitoreo diario: 3-4 min (08:00-16:00 servidor)
- Checklist diario en `Protocolo_Forward_Testing.md`
- Acción solo si: "robot rojo" o "P&L extremo"

**Día 8-21 (0.75% risk)**
- Si Día 1-7 cumple:
  - ✓ No se activaron protecciones
  - ✓ Profit Factor ≥ 1.2
  - ✓ Drawdown ≤ 10%
- Aumentar RiskPercent a 0.75%

**Día 22+ (1.0% risk)**
- Si Día 8-21 cumple mismos criterios
- Aumentar a configuración nominal

### Paso 3: Monitoreo Continuo

**Diario**:
- Equity actual vs. equity anterior
- Contador de operaciones
- Status indicator (rojo = problema)

**Semanal**:
- Profit Factor acumulado
- Drawdown máximo
- Win Rate semanal

**Mensual**:
- Reporte completo (ver template abajo)

---

## Protocolos de Emergencia

Ver: `Procedimientos_Emergencia.md` (usuario final)

### Situaciones CRÍTICAS (Detener Inmediatamente)

- Equity cayó > 10% en 1 hora
- "Insufficient Margin" error
- Conexión perdida > 5 minutos
- Spread > 500 puntos

**Acción**: Deactivate Algorithm Trading (MT5 icon button)

---

## Monitoreo en VPS 24/5

### Instalación en VPS

1. **Copy files** a directorio MT5 en VPS
2. **Configure Auto-Start**
   ```
   MT5.exe /portable
   ```
3. **Configura Remote Desktop** para acceso
4. **Set Alerts** en MT5
   - drawdown > 10% diario
   - trade loss > 2% equity
   - margin level < 200%

### Checklist VPS

- [ ] MT5 inicia automáticamente
- [ ] EA carga automáticamente en chart
- [ ] Algoritmo Trading activado
- [ ] Notificaciones configuradas
- [ ] Acceso remoto probado
- [ ] Backup de configuración guardado

---

## Reportes Mensuales

### Template de Reporte

```markdown
# Reporte Operacional - [MES/AÑO]

## Métricas de Desempeño
- **Equity Final**: $[X,XXX]
- **Ganancia Neta**: $[X,XXX]
- **Return %**: [X.X]%
- **Profit Factor**: [X.XX]
- **Drawdown Máximo**: [XX]%
- **Win Rate**: [XX]%

## Operaciones
- **Total Trades**: [XX]
- **Trades Ganadores**: [XX] ([XX]%)
- **Trades Perdedores**: [XX] ([XX]%)
- **Racha Máxima**: [XX] ganancias / [XX] pérdidas

## Incidentes
- [ ] Ninguno
- [ ] [Describe incidente, resolución]

## Cambios Realizados
- [ ] Ninguno
- [ ] [RiskPercent cambio a XX%]
- [ ] [Parámetro BB_Period ajustado]

## Aprobación
- Operador: ___________
- Ingeniero: ___________
- Fecha: ___________
```

---

## Listado de Control Pre-Producción

### Trading Directo
- [ ] Backtesting aprobado (Profit Factor ≥ 1.4)
- [ ] Forward testing 30 días completado
- [ ] Parámetros finales confirmados
- [ ] Comisiones reales validadas
- [ ] Margen suficiente (≥ 2x requerido)
- [ ] Conexión a broker estable
- [ ] Alertas configuradas en MT5
- [ ] Procedimientos de emergencia impresos

### VPS (si aplica)
- [ ] VPS accesible y confiable
- [ ] MT5 inicia automáticamente
- [ ] EA carga automáticamente
- [ ] Remote desktop probado
- [ ] Backup de configuración guardado

### Escalado
- [ ] Fase 1 (0.5%) completada ✓
- [ ] Fase 2 (0.75%) autorizada
- [ ] Fase 3 (1.0%) en calendario

---

## Desactivación de Emergencia

Si ocurre CUALQUIER problema:

1. **Inmediato**: 
   ```
   MT5 → Tools icon → Deactivate "Algorithm Trading"
   ```

2. **Cerrar posiciones abiertas**:
   - Manual (si es necesario)
   - O esperar cierre normal del robot

3. **Notificar**:
   - Ingeniero responsable
   - Documentar incidente

4. **Investigar**:
   - Revisar logs de MT5
   - Contactar soporte broker si falla técnica
