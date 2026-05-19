# CHANGELOG

Historial de versiones del BB_BTC_EA.

## [v8.3] - 2026-05-19

### Mejora de Robustez
- Eliminado el Take Profit estático en `ExecuteTrade()` para que las salidas sean 100% dinámicas por mercado.
- Implementada lógica de cierre de posición en `ClosePositionIfNeeded()` al cierre de vela diaria.
- Añadido retry loop en `HistoryDealSelect()` con hasta 3 intentos y `Sleep(5)` para mejorar la sincronización de DEAL_ADD.
- Optimizado `GetRecentLow()` con `CopyLow()` y `ArrayMinimum()` para reducir latencia y uso de memoria.
- Actualizada versión interna del EA a `8.3`.

## [v8.1] - 2026-05-18

### Seguridad
- **PositionExists()**: Añadida validación explícita con `PositionSelectByTicket()` antes de leer propiedades de posición
  - Evita lecturas de memoria inválidas en enumeración de posiciones
- **CalculateLotSize()**: Añadida guardián para SYMBOL_VOLUME_STEP <= 0
  - Previene división por cero en símbolos exóticos

### Mantenimiento
- Auditoría estática completada: revisión de patrones de riesgo
- Documentación técnica formalizada

## [v8.0] - 2026-04-01

### Características
- Arquitectura event-driven: validación secuencial en OnTick()
- 3 capas de protección de riesgo:
  - Límite por-transacción (%equity)
  - Contador de pérdidas consecutivas (protección racha)
  - Drawdown diario máximo (5% default)
- Compatibilidad con accounts Netting & Hedging
- Auto-detección de modo de llenado (FOK/IOC)
- Gestión de transacciones para loss tracking

### Parámetros Configurables
- RiskPercent, BB_Period, BB_Deviation
- StopLossPoints, TakeProfitPoints
- MaxRetriesPerBar, MaxSpreadPoints
- MaxConsecutiveLosses, MaxDailyDrawdownPercent
- MagicNumber

## [v7.0] - 2025-12-01

### Características Iniciales
- Indicador Bollinger Bands (mean-reversion)
- OnTick execution loop con validaciones
- Risk-based lot sizing
- Retry logic para requotes
- Daily reset tracking
