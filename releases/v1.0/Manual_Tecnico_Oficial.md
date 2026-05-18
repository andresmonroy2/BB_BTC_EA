# MANUAL TÉCNICO OFICIAL

BB_BTC_EA_v8_1

Versión 1.0 – Institutional Hardening Edition
Plataforma: MetaTrader 5
Documento Técnico Normativo para Implementación y Validación Cuantitativa
Clasificación: Uso Profesional / Gestión Financiera

## 1. Alcance del Documento

El presente manual establece:

- La arquitectura operativa del sistema.
- El modelo de ejecución y control de riesgo.
- Las métricas obligatorias de evaluación cuantitativa.
- El protocolo formal de validación mediante backtesting y forward testing.
- Las condiciones mínimas para despliegue en entorno real.

Este documento está dirigido a profesionales en ingeniería financiera, análisis cuantitativo y gestión de riesgo.

## 2. Descripción General del Sistema

- Nombre del sistema: BB_BTC_EA_v8_1
- Tipo: Expert Advisor (EA) para MetaTrader 5
- Modelo estratégico: Reversión a la media basada en Bandas de Bollinger
- Arquitectura: Control de riesgo multicapa con ejecución síncrona y monitoreo asíncrono de transacciones

El sistema ejecuta decisiones exclusivamente sobre velas cerradas, evitando señales basadas en ruido intrabar.

## 3. Arquitectura Funcional

### 3.1 Flujo Secuencial de Validación

El sistema ejecuta el siguiente flujo en cada evento de mercado:

- `OnTick`
  - Validación de conexión y permisos
  - Control de drawdown diario
  - Control de pérdidas consecutivas
  - Sincronización de nueva vela
  - Validación de spread
  - Cálculo de lote por riesgo porcentual
  - Validación de margen libre
  - Envío de orden

Ninguna orden es enviada si una sola validación falla.

## 4. Modelo Estratégico

### 4.1 Indicador Base

Bandas de Bollinger configuradas por:

- Periodo: `BB_Period`
- Desviación estándar: `BB_Deviation`
- Precio base: Cierre

### 4.2 Lógica de Entrada

- Cierre previo > Banda Superior → Venta
- Cierre previo < Banda Inferior → Compra

La evaluación se realiza en índice 1 (vela cerrada).

## 5. Gestión de Riesgo Institucional

El sistema incorpora tres niveles de protección:

### 5.1 Riesgo por Operación

- Parámetro: `RiskPercent`

El lote se calcula en función de:

- Equidad actual
- Distancia real al Stop Loss
- Valor del tick del instrumento
- Restricciones de volumen del broker
- Margen libre disponible

La fórmula estructural aplicada:

Lote = (Equity × RiskPercent) / ValorMonetarioSL

No se permite redondeo hacia arriba (uso de truncamiento con MathFloor).

### 5.2 Límite de Pérdidas Consecutivas

- Parámetro: `MaxConsecutiveLosses`

Si se alcanza el límite:

- El sistema se bloquea.
- Requiere intervención manual para reactivación.

### 5.3 Límite de Drawdown Diario

- Parámetro: `MaxDailyDrawdownPercent`

Si el drawdown diario supera el umbral:

- Se activa bloqueo automático.
- Reinicio automático al cambio de día del servidor.

## 6. Parámetros Técnicos Oficiales

| Parámetro | Función |
|---|---|
| `RiskPercent` | Exposición por operación |
| `StopLossPoints` | Límite de pérdida técnica |
| `TakeProfitPoints` | Objetivo de beneficio |
| `MaxSpreadPoints` | Control de liquidez |
| `SlippagePoints` | Tolerancia de ejecución |
| `MaxRetriesPerBar` | Control anti-recote |
| `MaxConsecutiveLosses` | Protección secuencial |
| `MaxDailyDrawdownPercent` | Protección diaria |
| `MagicNumber` | Identificación del sistema |

## 7. Métricas de Evaluación Cuantitativa

Antes de desplegar en real, el sistema debe cumplir criterios mínimos.

### 7.1 Métricas Primarias Obligatorias

- Expectancy (Esperanza Matemática): Debe ser positiva

  E = (WinRate × AvgWin) − (LossRate × AvgLoss)

- Profit Factor (PF): Recomendado ≥ 1.4

- Drawdown Máximo Relativo: Recomendado ≤ 25%

- Ratio Riesgo/Recompensa Promedio (R:R): Mínimo 1.2

- Win Rate Consistente: Evaluado junto al R:R, no de forma aislada.

### 7.2 Métricas Avanzadas Recomendadas

- Sharpe Ratio ≥ 1.0
- Sortino Ratio ≥ 1.2
- Recovery Factor ≥ 2
- Calmar Ratio ≥ 1.5

Estas métricas deben evaluarse sobre un periodo mínimo de 2 años históricos o al menos 200 operaciones.

## 8. Protocolo de Validación – Backtesting

### 8.1 Configuración del Strategy Tester

En MetaTrader 5:

- Abrir Strategy Tester.
- Modo: "Every tick based on real ticks".
- Modelado: Máxima precisión disponible.
- Spread: Real o variable.
- Comisión: Configurada según broker real.
- Periodo histórico: ≥ 24 meses.
- Capital inicial: Simulación realista según cuenta objetivo.

### 8.2 Criterios de Aprobación

El sistema se considera validado si:

- Cumple métricas mínimas.
- No presenta errores de ejecución.
- No existen picos anómalos de drawdown.
- No presenta clustering extremo de pérdidas.

## 9. Protocolo de Forward Testing

Antes del despliegue en cuenta real:

### 9.1 Fase Demo

- Duración mínima recomendada: 30 días.

Debe validarse:

- Coherencia entre backtest y forward.
- Estabilidad del spread.
- Ausencia de errores técnicos.
- Funcionamiento correcto del filtro de drawdown diario.

### 9.2 Fase Real Escalada

Despliegue progresivo:

- Cuenta pequeña.
- Riesgo reducido (ej. 0.5%).
- Supervisión manual durante primeras semanas.

Escalamiento solo tras estabilidad demostrada.

## 10. Gestión de Emergencias

- Detención inmediata: Botón global "Trading Algorítmico" → OFF.
- Detención individual: Gráfico → Asesores Expertos → Eliminar.

Las órdenes abiertas permanecen protegidas por SL en el servidor.

## 11. Limitaciones del Sistema

El EA:

- Ejecuta reglas con disciplina matemática
- Controla riesgo estructural
- Mitiga errores operativos humanos

No:

- Elimina riesgo de mercado
- Garantiza retornos positivos
- Sustituye análisis macroeconómico

## 12. Conclusión Técnica

BB_BTC_EA_v8_1 es un sistema de ejecución cuantitativa con arquitectura robusta, diseñado para operar bajo disciplina financiera estricta.

Su idoneidad para entorno real depende exclusivamente de:

- Parametrización adecuada.
- Validación estadística rigurosa.
- Gestión responsable del riesgo.
