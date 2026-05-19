# Estrategia Algorítmica: Bandas de Bollinger (XBT/USD)

## 1. Especificaciones del Activo y Parámetros
- [cite_start]**Activo**: Bitcoin (XBT/USD)[cite: 4, 18].
- [cite_start]**Ticker Bloomberg**: XBTUSD[cite: 19].
- [cite_start]**Temporalidad**: Diario (1D)[cite: 21, 43].
- [cite_start]**Periodos Bollinger (n)**: 19[cite: 42].
- [cite_start]**Multiplicador (k) Banda Superior**: 2.2[cite: 42].
- [cite_start]**Multiplicador (k) Banda Inferior**: 2.0[cite: 43].

## 2. Lógica Operacional
### Condiciones de Entrada (LONG)
- [cite_start]**Regla**: Precio de cierre $\leq$ Banda Inferior[cite: 55].
- [cite_start]**Confirmación (Opcional)**: Vela subsiguiente debe cerrar por encima de la banda inferior[cite: 57].
- [cite_start]**Acción**: Abrir posición LONG[cite: 59].

### Condiciones de Salida (Cierre)
- [cite_start]**Regla A**: Precio de cierre $>$ Banda Superior[cite: 62].
- [cite_start]**Regla B (Alternativa)**: Precio cruza la media móvil central[cite: 64].
- [cite_start]**Regla C (Stop Loss)**: Precio de cierre $\leq$ Stop Loss[cite: 82].

## 3. Gestión de Riesgo
- [cite_start]**Riesgo por operación**: 1% - 2% del capital total[cite: 86, 87].
- **Stop Loss (Opciones)**:
    - [cite_start]Debajo del mínimo reciente[cite: 91].
    - [cite_start]Porcentual fijo (ej. -3%)[cite: 95].
- **Take Profit (Opciones)**:
    - [cite_start]Conservador: Cerrar en la media móvil[cite: 99].
    - [cite_start]Agresivo: Cerrar en banda superior[cite: 101].

## 4. Arquitectura de Software Sugerida
- [cite_start]**Lenguaje**: Python[cite: 155].
- [cite_start]**Librerías**: `pandas`, `numpy`, `ta`, `backtesting`, `ccxt`, `matplotlib` [cite: 157-162].
- **Módulos del Sistema**:
    1. [cite_start]**Data Feed**: Conexión vía API (Binance, Coinbase, Bloomberg) [cite: 131-135].
    2. [cite_start]**Motor de Estrategia**: Cálculo de bandas, señales y riesgo [cite: 136-140].
    3. [cite_start]**Execution Engine**: Gestión de órdenes de compra/venta [cite: 141-143].
    4. [cite_start]**Risk Manager**: Control de tamaño de posición, SL y exposición [cite: 144-148].
    5. [cite_start]**Logging System**: Registro de operaciones, errores y métricas [cite: 149-152].

## 5. Restricciones del Sistema
- [cite_start]Solo una posición abierta simultáneamente[cite: 66].
- [cite_start]No abrir compra si existe una posición LONG activa[cite: 67].
- [cite_start]No operar bajo condiciones de baja liquidez[cite: 68].
- [cite_start]Ejecución exclusiva al cierre de vela diaria[cite: 69].

## 6. Resultados de Backtesting (Bloomberg)
- [cite_start]**Retorno total**: 190.65%[cite: 104].
- [cite_start]**Ratio Sharpe**: 4.93[cite: 104].
- [cite_start]**Winning Rate**: 86.67%[cite: 104].
- [cite_start]**Max Drawdown**: 22.19%[cite: 104].