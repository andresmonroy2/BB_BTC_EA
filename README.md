# BB_BTC_EA_v8_1 — Expert Advisor para MetaTrader 5

BB_BTC_EA_v8_1 es un Expert Advisor MQL5 para trading sistemático con BTC/USD, diseñado para operar bajo criterios de robustez, control de riesgo y trazabilidad técnica.

---

##  Resumen técnico

Este repositorio incluye:

- `src/BB_BTC_EA_v8_1.mq5` — código fuente del EA
- `src/config/default_parameters.set` — parámetros recomendados de lanzamiento
- `releases/v1.0/` — paquete de entrega listo para auditoría
- `docs/` — documentación técnica y de despliegue en español

---

##  Estructura del repositorio

- `src/` — código fuente, parámetros y placeholders modulares
- `docs/` — manual técnico, especificación de riesgo y protocolos de validación
- `releases/v1.0/` — entrega formal del release
- `README.md` — visión general y accesos rápidos

---

##  Documentación clave

- [Manual técnico oficial](./docs/Manual_Tecnico_Oficial.md)
- [Especificación de gestión de riesgos](./docs/RISK_MANAGEMENT_SPEC.md)
- [Protocolo de validación de backtesting](./docs/BACKTEST_VALIDATION_PROTOCOL.md)
- [Guía de despliegue](./docs/DEPLOYMENT_GUIDE.md)
- [Changelog del proyecto](./docs/CHANGELOG.md)
- [Guía de instalación](./Guia_Instalacion.md)
- [Protocolo de forward testing](./Protocolo_Forward_Testing.md)
- [Procedimientos de emergencia](./Procedimientos_Emergencia.md)

---

##  Objetivo del proyecto

Desarrollar un EA para MT5 con:

- Gestión de riesgo cuantitativa
- Controles de validación en tiempo de ejecución
- Compatibilidad Netting y Hedging
- Auditoría técnica explícita
- Preparación para transition a ambiente real

---

##  Arquitectura del EA

BB_BTC_EA_v8_1 sigue una arquitectura orientada a eventos y validaciones secuenciales.

### Flujo principal

1. `OnInit()` — inicializa indicadores, parámetros y contadores diarios
2. `OnTick()` — ejecuta validaciones de conexión, protección y señal
3. `ExecuteTrade()` — gestiona órdenes con lógica de slippage y re-quote
4. `OnTradeTransaction()` — actualiza contador de pérdidas y estado de trade

### Módulos y responsabilidades

- `Strategy` — análisis de Bollinger Bands y generación de señales
- `RiskManager` — sizing de lotes y validación de límites del broker
- `ExecutionEngine` — envío de órdenes, comprobación de estado y reintentos
- `Logger` — trazabilidad de errores y estados operativos

> La arquitectura está documentada en: [Manual técnico oficial](./docs/Manual_Tecnico_Oficial.md)

---

##  Control de riesgo

Protecciones implementadas:

- `RiskPercent` — porcentaje de capital por operación
- `MaxConsecutiveLosses` — límite de racha negativa
- `MaxDailyDrawdownPercent` — circuito de cierre diario
- `MaxSpreadPoints` — filtro de ejecución en spread elevado
- `StopLossPoints` y `TakeProfitPoints` — gestión de salida fija

Este diseño busca limitar la exposición por trade y preservar capital durante condiciones adversas.

> Ver especificación detallada en: [RISK_MANAGEMENT_SPEC.md](./docs/RISK_MANAGEMENT_SPEC.md)

---

##  Validación y pruebas

Se recomienda un proceso de validación estructurado:

1. Backtest completo con datos históricos reales
2. Walk-forward validation para comprobar robustez
3. Forward testing en demo
4. Escalado progresivo en cuenta real

> Protocolo completo en: [BACKTEST_VALIDATION_PROTOCOL.md](./docs/BACKTEST_VALIDATION_PROTOCOL.md)

---

##  Requisitos de instalación

- MetaTrader 5 en Windows
- MetaEditor para compilación
- Símbolo BTCUSD o equivalente disponible
- Históricos de al menos 24 meses
- Acceso a una cuenta demo o real para pruebas

---

##  Instrucciones rápidas

1. Copia `src/BB_BTC_EA_v8_1.mq5` a `MQL5/Experts/`
2. Compila con MetaEditor
3. Carga el EA en un gráfico BTCUSD
4. Importa `src/config/default_parameters.set`
5. Activa `AutoTrading` y `Permitir trading algorítmico`
6. Confirma estado y logs en MT5

> Para el procedimiento completo, consulta: [Guía de instalación](./Guia_Instalacion.md)

---

##  Release y entrega

Entrega del release:

- `releases/v1.0/BB_BTC_EA_v8_1.mq5`
- `releases/v1.0/default_parameters.set`
- `releases/v1.0/Manual_Tecnico_Oficial.md`

> El release está preparado para distribución y revisión técnica.

---

##  Procedimientos de emergencia

En caso de anomalía operativa:

- Desactiva `AutoTrading`
- Revisa el log de MT5
- Verifica estado de la cuenta y margen
- Si es necesario, detén el EA

> Detalles en: [Procedimientos de emergencia](./Procedimientos_Emergencia.md)

---

##  Notas finales

Este proyecto está diseñado para validación técnica y auditoría previa a su uso en producción. El trading conlleva riesgo; operar en real requiere validación completa y administración disciplinada.

> Consulta el historial de cambios en: [docs/CHANGELOG.md](./docs/CHANGELOG.md)
