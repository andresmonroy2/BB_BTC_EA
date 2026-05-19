# BB_BTC_EA_v8_1 — Expert Advisor para MetaTrader 5 (interno v8.3)

BB_BTC_EA_v8_1 es un Expert Advisor MQL5 orientado a trading sistemático de BTC/USD sobre MetaTrader 5. El código fuente interno está actualizado a la versión `8.3`, con gestión de salidas dinámicas y robustez de ejecución mejorada en entornos de capital real.

---

## Resumen técnico

Este repositorio contiene:

- `src/BB_BTC_EA_v8_1.mq5` — código fuente del EA auditado
- `src/config/default_parameters.set` — configuración recomendada de lanzamiento
- `releases/v1.0/` — paquete de entrega preparado para distribución
- `docs/` — documentación técnica en español
- `tests/`, `research/`, `logs/` — estructura de soporte para validación y seguimiento

---

## Estructura del repositorio

- `src/` — código fuente principal y configuración de parámetros
- `src/includes/` — módulos y stubs para futura modularización
- `src/config/` — parámetros de carga inicial
- `docs/` — especificaciones, protocolos y manuales
- `releases/v1.0/` — bundle de entrega del release
- `tests/` — scripts y documentación de pruebas
- `research/` — análisis históricos y backtests
- `logs/` — notas de desarrollo y auditoría

---

## Documentación clave

- [Manual técnico oficial](./docs/Manual_Tecnico_Oficial.md)
- [Especificación de gestión de riesgos](./docs/RISK_MANAGEMENT_SPEC.md)
- [Protocolo de validación de backtesting](./docs/BACKTEST_VALIDATION_PROTOCOL.md)
- [Guía de despliegue](./docs/DEPLOYMENT_GUIDE.md)
- [Changelog del proyecto](./docs/CHANGELOG.md)
- [Guía de instalación](./Guia_Instalacion.md)
- [Protocolo de forward testing](./Protocolo_Forward_Testing.md)
- [Procedimientos de emergencia](./Procedimientos_Emergencia.md)

---

## Objetivo del proyecto

Crear un EA para MT5 con:

- Gestión de riesgo basada en porcentaje de equity
- Circuitos de protección por drawdown diario y pérdidas consecutivas
- Validación de órdenes y control de ejecución
- Compatibilidad con cuentas Netting y Hedging
- Preparación para validación cuantitativa y auditoría técnica

---

## Arquitectura técnica

BB_BTC_EA_v8_1 aplica una arquitectura orientada a eventos con validaciones secuenciales.

### Flujo principal

1. `OnInit()`
   - Inicializa indicadores Bollinger Bands
   - Carga parámetros de entrada
   - Establece estados de protección diaria
2. `OnTick()`
   - Verifica conexión y estado del símbolo
   - Comprueba drawdown diario y límite de pérdidas consecutivas
   - Evita nuevas órdenes si ya existe posición abierta
   - Evalúa señal de trading y ejecuta orden si es válido
3. `ExecuteTrade()`
   - Calcula lotaje seguro
   - Aplica controles de spread y slippage
   - Reintenta en re-quotes hasta `MaxRetriesPerBar`
4. `OnTradeTransaction()`
   - Monitorea cierres de operaciones
   - Actualiza contador de pérdidas consecutivas
   - Registra resultados para control de riesgo

### Diseño de módulos

- `Strategy` — detección de señales desde Bollinger Bands
- `RiskManager` — sizing de lotes y validaciones de límites broker
- `ExecutionEngine` — ejecución de órdenes y manejo de errores API
- `Logger` — trazabilidad de eventos y estados críticos

> Detalles de diseño y diagrama de flujo en: [Manual técnico oficial](./docs/Manual_Tecnico_Oficial.md)

---

## Controles de seguridad y robustez

### Validaciones clave

- `PositionExists()` usa `PositionSelectByTicket()` antes de leer propiedades de posición
  - Evita lecturas inválidas en enumeración de posiciones abiertas
- `CalculateLotSize()` valida `SYMBOL_VOLUME_STEP > 0`
  - Previene división por cero en símbolos exóticos
- `MaxSpreadPoints` bloquea entradas en condiciones de mercado adversas
- `MaxConsecutiveLosses` evita continuar tras una racha negativa
- `MaxDailyDrawdownPercent` detiene nuevas entradas cuando el drawdown diario es crítico

### Protección contra errores API

- Verificación explícita de `OrderSend()` y `PositionClose()`
- Reintentos controlados para `REQUOTE`
- Manejo de respuestas de `TradeResult`

---

## Parámetros técnicos clave

| Parámetro | Función | Valor por defecto |
|-----------|---------|-------------------|
| `RiskPercent` | Riesgo por trade (% equity) | `1.0` |
| `BB_Period` | Periodo de Bollinger Bands | `20` |
| `BB_Deviation` | Desviación de Bollinger Bands | `2.0` |
| `StopLossPoints` | Stop loss en puntos | `1000` |
| `TakeProfitPoints` | Take profit en puntos | `1500` |
| `MaxSpreadPoints` | Máximo spread permitido | `300` |
| `SlippagePoints` | Slippage máximo aceptado | `50` |
| `MaxConsecutiveLosses` | Pérdidas consecutivas permitidas | `3` |
| `MaxDailyDrawdownPercent` | Drawdown diario máximo | `5.0` |
| `MagicNumber` | Identificador exclusivo del EA | `888888` |

> Ver parámetros completos y su descripción en: [Guía de instalación](./Guia_Instalacion.md)

---

## Validación recomendada

Proceso mínimo:

1. Backtesting con datos reales y spread histórico
2. Walk-forward validation en múltiples ventanas
3. Forward testing en demo
4. Escalado gradual en real

### Criterios de aceptación iniciales

- Profit Factor ≥ 1.4
- Drawdown máximo ≤ 25%
- Win Rate ≥ 40%
- Consistencia en walk-forward ≥ 3 de 4 ventanas

> Protocolo completo: [BACKTEST_VALIDATION_PROTOCOL.md](./docs/BACKTEST_VALIDATION_PROTOCOL.md)

---

## Requisitos de compilación

- MetaTrader 5 en Windows
- MetaEditor para compilar `BB_BTC_EA_v8_1.mq5`
- Símbolo BTCUSD o equivalente disponible en el broker
- Históricos de al menos 24 meses
- Cuenta demo o real para pruebas

### Nota de compilación

- El archivo fuente `src/BB_BTC_EA_v8_1.mq5` debe compilarse en `.ex5`
- El binario exportado se debe usar desde `MQL5/Experts/`

---

## Instrucciones de despliegue rápido

1. Copia `src/BB_BTC_EA_v8_1.mq5` a `MQL5/Experts/`
2. Abre MetaEditor y compila el archivo
3. Abre MT5 y coloca el EA en un gráfico BTCUSD
4. Importa `src/config/default_parameters.set`
5. Activa `AutoTrading` y `Permitir trading algorítmico`
6. Verifica la ventana del experto para confirmar estado y mensajes

> Consulta el proceso completo en: [Guía de instalación](./Guia_Instalacion.md)

---

## Entrega y release

Bundle de entrega:

- `releases/v1.0/BB_BTC_EA_v8_1.mq5`
- `releases/v1.0/default_parameters.set`
- `releases/v1.0/Manual_Tecnico_Oficial.md`

> El release está preparado para auditoría técnica y uso de revisión.

---

## Procedimientos de emergencia

Si el EA presenta comportamiento anómalo:

- Desactiva `AutoTrading`
- Revisa los logs y la pestaña "Experts"
- Verifica nivel de margen y estado de la cuenta
- Si es necesario, detén el EA y notifica al responsable

> Procedimientos completos: [Procedimientos de emergencia](./Procedimientos_Emergencia.md)

---

## Notas finales

Este repositorio está concebido para validación técnica rigurosa antes de producción. El trading conlleva riesgo; la implementación en real debe basarse en backtest, walk-forward y forward test completos.

> Historial de cambios: [docs/CHANGELOG.md](./docs/CHANGELOG.md)
