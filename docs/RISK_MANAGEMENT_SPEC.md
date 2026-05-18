# Especificación de Gestión de Riesgos

## Descripción General

El BB_BTC_EA implementa un modelo de riesgo institucional con 3 capas de protección:
1. **Riesgo por transacción individual** (% del equity)
2. **Protección de racha de pérdidas** (máximo N pérdidas consecutivas)
3. **Límite de drawdown diario** (máximo % pérdida en 24h)

---

## Capa 1: Riesgo por Transacción

### Fórmula
```
Risk $ = Equity × RiskPercent / 100
Distance $ = (Entry Price - Stop Loss) × Contract Size
Lot Size = Risk $ / Distance $
```

### Respeto a Límites del Broker
- Mínimo lot: `SYMBOL_VOLUME_MIN`
- Máximo lot: `SYMBOL_VOLUME_MAX`
- Step: `SYMBOL_VOLUME_STEP`

### Parámetros
- **RiskPercent** (default: 1.0%)
  - Máximo recomendado: 2.0%
  - Mínimo operativo: 0.1%

### Validaciones
- `SYMBOL_VOLUME_STEP > 0` (previene división por cero)
- `RiskPercent > 0` (debe ser positivo)
- Lot final respeta `[VOLUME_MIN, VOLUME_MAX]`

---

## Capa 2: Protección de Racha de Pérdidas

### Mecanismo
- Contador de **pérdidas consecutivas** (trades cerrados con P&L < 0)
- Cuando alcanza `MaxConsecutiveLosses` → **detiene nuevas órdenes**
- Se reinicia al completar un trade ganador

### Implementación
- Evento: `OnTradeTransaction()` captura `DEAL_ENTRY_OUT` (cierre)
- Verifica: `DEAL_PROFIT < 0` para incrementar contador
- Reset: cuando `DEAL_PROFIT >= 0`

### Parámetros
- **MaxConsecutiveLosses** (default: 3)
  - Protege contra ciclos de drawdown rápido
  - Permite al operador validar cambios de mercado

### Ejemplo
```
Trade 1: -100 USD (contador = 1)
Trade 2: -50 USD (contador = 2)
Trade 3: -75 USD (contador = 3, STOP - no nuevo trade)
Trade 4 (cuando contador reset): OK
```

---

## Capa 3: Límite de Drawdown Diario

### Mecanismo
- Seguimiento de pérdidas acumuladas en **24 horas servidor**
- Reinicio automático cada día (00:00 server time)
- Cuando DrawdownActual >= `MaxDailyDrawdownPercent` → **STOP**

### Fórmula
```
DrawdownPct = (Equity_Inicial - Equity_Actual) / Equity_Inicial × 100
```

### Implementación
- Variable global: `dailyLossTracker` (USD)
- OnTick check: `dailyLossTracker >= MaxDailyDrawdownPercent × Equity`
- OnInit() o UTC 00:00: reset a cero

### Parámetros
- **MaxDailyDrawdownPercent** (default: 5.0%)
  - Protege contra "días malos"
  - Permite descanso y reanálisis

### Ejemplo
```
Equity: 10,000 USD
Límite diario 5%: $500 máximo de pérdida/día
Si alcanza -$500: STOP (sin nuevas órdenes)
```

---

## Matriz de Decisión OnTick()

```
┌─────────────────────────────────────────────────────────┐
│ 1. ¿Conexión activa? → NO → EXIT                        │
├─────────────────────────────────────────────────────────┤
│ 2. ¿Drawdown diario OK? → NO → EXIT                     │
├─────────────────────────────────────────────────────────┤
│ 3. ¿Posición abierta? → SÍ → EXIT (una por vez)         │
├─────────────────────────────────────────────────────────┤
│ 4. ¿Pérdidas consecutivas OK? → NO → EXIT               │
├─────────────────────────────────────────────────────────┤
│ 5. ¿Spread < MaxSpreadPoints? → NO → EXIT               │
├─────────────────────────────────────────────────────────┤
│ 6. ¿Signal generado (BB)? → SÍ → ExecuteTrade()         │
└─────────────────────────────────────────────────────────┘
```

---

## Métricas de Auditoría

Para validar que el sistema funciona:

| Métrica | Método | Umbral |
|---------|--------|--------|
| Profit Factor | Ganancias / Pérdidas | ≥ 1.4 |
| Drawdown Máximo | Min(Equity) / Max(Equity) | ≤ 25% |
| Win Rate | Trades Ganadores / Total | ≥ 40% |
| Sharpe Ratio | (Retorno - Rf) / StdDev(Retornos) | ≥ 1.0 |
| Drawdown Consecutivo | Max(N) pérdidas seguidas | ≤ 3 |
| Drawdown Diario | Max(pérdida/día) | ≤ 5% |

---

## Configuración Recomendada por Fase

### Fase Demo (Validación)
```
RiskPercent = 0.5 - 1.0%     (capital bajo, sin presión)
MaxConsecutiveLosses = 3     (estándar)
MaxDailyDrawdownPercent = 5% (estándar)
```

### Fase Real Inicial (0.5x)
```
RiskPercent = 0.5%           (mitad de producción)
MaxConsecutiveLosses = 3     
MaxDailyDrawdownPercent = 3% (más conservador)
```

### Fase Real Producción (1.0x)
```
RiskPercent = 1.0%           (configuración nominal)
MaxConsecutiveLosses = 3     
MaxDailyDrawdownPercent = 5% (estándar)
```
