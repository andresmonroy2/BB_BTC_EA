# Protocolo de Validación de Backtesting

## Objetivo

Establecer criterios objetivos y reproducibles para validar el desempeño del BB_BTC_EA antes de implementación en cuentas reales.

---

## Fase 1: Configuración de Strategy Tester

### Requisitos Previos
- **Plataforma**: MetaTrader 5 (Windows)
- **Datos**: Mínimo 24 meses históricos (BTC/USD H1)
- **Símbolo**: BTCUSD (o equivalente en tu broker)
- **Comisión**: Según tu broker real
- **Spread**: Spread real (no fijo; usar histórico)

### Configuración de Prueba

| Parámetro | Valor |
|-----------|-------|
| Símbolo | BTCUSD |
| Período | H1 (horario) |
| Desde | 24+ meses atrás |
| Hasta | Hoy |
| Modelo | "Every tick" (máxima precisión) |
| Optimización | Desactivada (solo prueba) |
| Comisiones | Real de broker |

### Parámetros del EA Iniciales

```
RiskPercent = 1.0%
BB_Period = 20
BB_Deviation = 2.0
StopLossPoints = 1000
TakeProfitPoints = 1500
MaxConsecutiveLosses = 3
MaxDailyDrawdownPercent = 5.0
MagicNumber = 888888
```

---

## Fase 2: Métricas de Aceptación

### Criterios Mínimos Obligatorios

| Métrica | Umbral | Razón |
|---------|--------|-------|
| **Profit Factor** | ≥ 1.4 | Ganancia/Pérdida ratio (1.4x = 40% ganancia neta) |
| **Max Drawdown** | ≤ 25% | Protección capital (tolerable máximo) |
| **Win Rate** | ≥ 40% | Mínimo de trades ganadores |
| **Sharpe Ratio** | ≥ 1.0 | Rendimiento ajustado por volatilidad |
| **Total Trades** | ≥ 50 | Muestra estadística mínima |

### Métricas Secundarias (Contexto)

| Métrica | Qué Indica |
|---------|-----------|
| Recovery Factor | Ganancia neta / Drawdown máximo (ideal ≥ 2.0) |
| Expectation | Ganancia promedio por trade (debe ser positivo) |
| Consecutive Wins/Losses | Racha máxima (ideal ≤ 5) |
| Monthly Balance Change % | Estabilidad mes-a-mes |

---

## Fase 3: Walk-Forward Validation

Divide el histórico en ventanas para validar robustez.

### Procedimiento

1. **Divide datos en 4 períodos de 6 meses cada uno**
   ```
   Ventana 1: Meses 1-6
   Ventana 2: Meses 7-12
   Ventana 3: Meses 13-18
   Ventana 4: Meses 19-24
   ```

2. **Ejecuta backtest en cada ventana**
   - Anota Profit Factor, Drawdown, Win Rate

3. **Calcula promedio de métricas**
   ```
   PF_Promedio = (PF_V1 + PF_V2 + PF_V3 + PF_V4) / 4
   DD_Promedio = (DD_V1 + DD_V2 + DD_V3 + DD_V4) / 4
   ```

4. **Valida consistencia**
   - Aceptación: PF ≥ 1.4 en ≥ 3/4 ventanas
   - Aceptación: DD ≤ 25% en todas las ventanas

### Tabla de Resultados

```markdown
| Período | PF | DD% | WR% | Trades | Status |
|---------|-----|-----|-----|--------|--------|
| V1 (1-6M) | 1.45 | 18% | 42% | 67 | ✓ PASS |
| V2 (7-12M) | 1.32 | 22% | 38% | 54 | ✓ PASS |
| V3 (13-18M) | 1.58 | 15% | 45% | 78 | ✓ PASS |
| V4 (19-24M) | 1.41 | 24% | 41% | 61 | ✓ PASS |
| **Promedio** | **1.44** | **20%** | **42%** | **65** | ✓ **VALIDATED** |
```

---

## Fase 4: Análisis de Curva de Equity

### Inspección Visual

Abre la curva de equity en MT5 Report y verifica:

1. **¿Tendencia creciente?**
   - Ideal: Curva suave hacia arriba
   - Rechazar: Curva plana o con caídas bruscas

2. **¿Volatilidad aceptable?**
   - Ideal: Oscilaciones graduales, no picos
   - Rechazar: Picos de drawdown > 25%

3. **¿Recovery rápido después de drawdowns?**
   - Ideal: Recupera 50%+ del drawdown en < 5 trades
   - Alerta: Recuperación > 10 trades = riesgo sistémico

### Checklist

- [ ] Curva comienza en base
- [ ] Crecimiento general positivo
- [ ] Drawdowns < 25%
- [ ] Recovery rápido
- [ ] No caídas catastróficas
- [ ] Sin "accidentes" al final (robustez reciente)

---

## Decisión Final: Aprobación/Rechazo

### Criterios de APROBACIÓN

✅ **Aprueba si:**
- Profit Factor ≥ 1.4
- Max Drawdown ≤ 25%
- Win Rate ≥ 40%
- Walk-forward consistency ≥ 3/4 ventanas
- Curva de equity estable y creciente

### Criterios de RECHAZO

❌ **Rechaza si:**
- Profit Factor < 1.4 (rentabilidad insuficiente)
- Max Drawdown > 25% (riesgo excesivo)
- Win Rate < 40% (fiabilidad baja)
- Walk-forward consistency < 3/4 ventanas (inestable)
- Equity curve con caídas catastróficas

### Criterios de REVISAR PARÁMETROS

🔄 **Requiere optimización si:**
- Metrics cerca del umbral (1.35 < PF < 1.40)
- Drawdown cercano al límite (23% < DD < 25%)
- Consistencia parcial (3/4 ventanas)

**Parámetros a revisar:**
- `BB_Period` (ajustar 15-25)
- `BB_Deviation` (ajustar 1.5-2.5)
- `StopLossPoints` (ajustar ±200)
- `MaxDailyDrawdownPercent` (si DD alto)

---

## Próximos Pasos Después de Aprobación

1. ✓ Backtest completo aprobado
2. → Forward testing en demo 30 días
3. → Validación con dinero real (0.5% risk inicial)
4. → Escalado a 1.0% risk después de 30 días reales confirmados
