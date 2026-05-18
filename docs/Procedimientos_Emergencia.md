# Procedimientos de Emergencia – BB_BTC_EA_v8_1

## Qué Hacer Si Algo Falla

---

## ¿Cuándo Usar Este Documento?

Si observas **cualquiera** de estos síntomas:

- El robot está rojo (inactivo)
- Errores en el Journal
- Pérdidas inesperadas
- El robot no abre operaciones
- Spread muy alto
- Margen insuficiente
- Cuenta bloqueada
- Conexión perdida

---

## Acción 1: DETÉN el Robot Inmediatamente

### Opción A: Detención Global (SEGURA - Recomendada)

**Pasos:**
1. En MetaTrader 5: **Herramientas** → **Opciones**
2. Pestaña: **Asesores Expertos**
3. Desmarca ✓ la opción: **Permitir el trading automático**
4. Click: **Aceptar**

**Resultado:**
- El robot se detiene **globalmente**
- Todas las posiciones abiertas permanecen protegidas por **Stop Loss en el servidor**
- No pierdes dinero de más

**Tiempo para ejecutar:** 30 segundos

---

### Opción B: Detención Local (solo este gráfico)

**Pasos:**
1. Haz clic derecho **en el gráfico**
2. **Asesores Expertos** → **Eliminar**
3. El robot desaparece del gráfico

**Resultado:**
- Solo se desactiva en **este** gráfico
- Si tienes el robot en otro gráfico, sigue funcionando
- Las posiciones permanecen protegidas

**Tiempo para ejecutar:** 10 segundos

**⚠️ NOTA:** Si tienes dudas, usa **Opción A** (global) — es más segura.

---

## Acción 2: Identifica el Problema

Abre el **Journal** para ver mensajes de error:

**Pasos:**
1. **Herramientas** → **Journal** (o presiona `Ctrl+J`)
2. Busca mensajes **rojos** (errores)
3. Lee el mensaje y toma nota

### Problemas Comunes y Soluciones

---

## Problema 1: "Expert advisor not allowed"

**Significa:** Trading automático no está permitido

**Solución:**
1. **Herramientas** → **Opciones**
2. Pestaña **Asesores Expertos**
3. Marca ✓ **Permitir el trading automático**
4. Click **Aceptar**
5. Haz doble clic en el gráfico → el robot debería reactivarse

**Tiempo:** 1 minuto

---

## Problema 2: "Insufficient Margin"

**Significa:** No tienes saldo suficiente para abrir una operación

**Síntoma:** El robot está verde pero no abre operaciones

**Soluciones:**

### A. Reducir el riesgo por operación
1. Click derecho en el gráfico → **Asesores Expertos** → **Editar entrada**
2. Busca parámetro: `RiskPercent`
3. Cambia de `1.0` a `0.5`
4. Click **Aceptar**

**Resultado:** Las próximas operaciones arriesgarán 0.5% en lugar de 1.0% (mitad del tamaño)

### B. Depositar más dinero
1. Contacta a tu broker
2. Haz un depósito a tu cuenta

**⚠️ Usa Opción A primero (es más seguro).**

**Tiempo:** 1 minuto (opción A)

---

## Problema 3: "Requote Detected" (aparece en Journal)

**Significa:** El precio cambió entre que el robot intentó entrar y el broker recibió la orden

**Es normal:** Bitcoin tiene spreads dinámicos. El robot intentará de nuevo.

**¿Qué hacer?**

**Opción 1: Aumentar tolerancia de slippage**
1. Click derecho en gráfico → **Asesores Expertos** → **Editar entrada**
2. Busca: `SlippagePoints`
3. Cambia de `50` a `75` (o `100`)
4. Click **Aceptar**

**Resultado:** El robot será más "flexible" con los precios. Entra más fácil pero puede tener un poco más de deslizamiento.

**Opción 2: Cambiar a broker con spreads más bajos**
- Algunos brokers tienen spreads fijos en crypto
- Contacta al soporte de tu broker

**Es urgente?** No, es comportamiento normal. Continúa monitoreando.

**Tiempo:** 1 minuto

---

## Problema 4: "MaxDailyDrawdown Protection Active" (en Journal)

**Significa:** El robot perdió dinero hoy y alcanzó el límite de pérdida diaria

**Acción:**
- El robot se **bloquea automáticamente** para el resto del día
- Se **reinicia automáticamente** mañana a las 00:00 (hora del servidor)

**¿Qué hacer?**
- ✗ No hagas nada manual
- ✓ Espera a mañana
- ✓ Revisa qué salió mal (toma notas del equity)

**Es normal?** Sí, es una protección diseñada. Significa que el robot funciona.

**Aumentar límite?**
1. Click derecho → **Asesores Expertos** → **Editar entrada**
2. Busca: `MaxDailyDrawdownPercent`
3. Cambia de `5.0` a `7.0` (o `8.0`)
4. Click **Aceptar**

**⚠️ CUIDADO:** Esto permite más pérdida diaria. Solo hazlo si entiendes las consecuencias.

**Tiempo:** 1 minuto

---

## Problema 5: "MaxConsecutiveLosses Limit Reached" (en Journal)

**Significa:** El robot tuvo 3 (o más) operaciones seguidas perdedoras

**Acción:**
- El robot se **bloquea** automáticamente
- Requiere **intervención manual** para reiniciar

**¿Qué hacer?**

### A. Esperar (opción conservadora)
- Elimina el robot del gráfico
- Espera 3-7 días sin robot
- Reinicia después

### B. Aumentar el límite
1. Click derecho → **Asesores Expertos** → **Editar entrada**
2. Busca: `MaxConsecutiveLosses`
3. Cambia de `3` a `4` o `5`
4. Click **Aceptar**

**¿Contactar a Andrés?** SÍ. Esto significa algo no está funcionando como se esperaba.

**Tiempo:** 1 minuto (pero contacta a Andrés después)

---

## Problema 6: Robot está ROJO (Inactivo)

**¿Por qué pasa?**
- Permiso de trading desactivado
- Error crítico
- MetaTrader no responde

**Soluciones (en orden):**

### Paso 1: Intenta reactivar
1. Haz **doble clic en el gráfico**
2. El robot debería ponerse verde

**¿Funcionó?** SÍ → Fin. Continúa monitoreando.
**¿No funcionó?** → Paso 2

### Paso 2: Elimina y recarga
1. Click derecho gráfico → **Asesores Expertos** → **Eliminar**
2. Arrastra el robot de nuevo (desde Navigator → Expert Advisors)
3. Configura parámetros
4. Click **Aceptar**

**¿Funcionó?** SÍ → Fin.
**¿No funcionó?** → Paso 3

### Paso 3: Reinicia MetaTrader
1. Cierra MetaTrader completamente
2. Espera 10 segundos
3. Abre MetaTrader de nuevo
4. Carga el robot

**¿Funcionó?** SÍ → Fin.
**¿No funcionó?** → Contacta a Andrés (hay un problema más profundo)

**Tiempo:** 3-5 minutos

---

## Problema 7: "Invalid Stop Loss" o "Invalid Price"

**Significa:** El broker rechazó la orden por parámetros inválidos

**Causas:**
- Stop Loss muy cerca del precio (broker requiere distancia mínima)
- Precio fuera de rango
- Broker tiene restricciones especiales

**Soluciones:**

### Opción A: Aumentar Stop Loss
1. Click derecho → **Asesores Expertos** → **Editar entrada**
2. Busca: `StopLossPoints`
3. Cambia de `1000` a `1200` (más distancia)
4. Click **Aceptar**

### Opción B: Contactar al broker
- El broker puede tener requisitos especiales
- Pregunta: ¿cuál es la distancia mínima permitida de SL?

**Tiempo:** 1 minuto

---

## Problema 8: Conexión Perdida (No Network)

**Significa:** MetaTrader perdió conexión con el broker

**¿Qué hace el robot?**
- Se detiene automáticamente
- No abre operaciones nuevas
- Las posiciones existentes permanecen protegidas

**¿Qué hago?**

1. **Verifica tu internet:**
   - ¿Otros programas funcionan? (navegador, etc.)
   - ¿El WiFi/cable está conectado?

2. **Verifica MetaTrader:**
   - ¿Dice "Desconectado" en la esquina inferior?
   - Espera 30 segundos — debería reconectar automáticamente

3. **Si sigue sin conexión:**
   - Cierra MetaTrader
   - Cierra tu VPS (si usas)
   - Reinicia router
   - Abre MetaTrader de nuevo

4. **Si el problema persiste:**
   - Contacta al soporte del broker
   - Contacta al soporte de tu VPS (si usas)

**Es urgente?** SÍ si tienes posiciones abiertas. Las posiciones están protegidas pero el robot no puede cerrar ni abrir operaciones.

**Tiempo para resolver:** 5-15 minutos

---

## Problema 9: "Margin Level Too Low"

**Significa:** Tu nivel de margen está cerca del mínimo (normalmente 20%)

**Ejemplo:**
- Depósito: $1,000
- Posiciones abiertas: $950 en margen usado
- Margen libre: $50
- Margen disponible: 5.3% (PELIGRO)

**¿Qué hace el robot?**
- Se detiene automáticamente (protección)
- No abre operaciones nuevas

**¿Qué hago?**

### Opción A: Cerrar posiciones manualmente
1. Panel derecha → **Posiciones**
2. Haz clic derecho en una posición
3. Click **Cerrar**
4. El margen se libera

### Opción B: Depositar más dinero
1. Contacta a tu broker
2. Haz un depósito

### Opción C: Reducir el riesgo futuro
1. Edita entrada del robot → `RiskPercent`
2. Baja de `1.0` a `0.5`
3. Las próximas operaciones serán más pequeñas

**¿Es urgente?** SÍ. Riesgo de Margin Call (pérdida total).

**Acción recomendada:** Opción B (deposita) + Opción C (reduce riesgo).

**Tiempo:** 5 minutos

---

## Problema 10: Pérdidas Mayores de lo Esperado

**Significa:** El equity bajó más de lo que backtest predecía

**¿Por qué?**
- Mercado cambió (volatilidad inesperada)
- Parámetros no optimizados
- Broker tiene spreads diferentes
- Slippage mayor que en backtest

**¿Qué hago?**

### Paso 1: Evalúa la situación
- ¿Cuánta pérdida has tenido? ($XXX)
- ¿Cuál era el drawdown máximo esperado? (5-25%)
- ¿Es razonable la pérdida?

### Paso 2: Decide
**Si la pérdida es < 10% del capital:**
- ✓ Continúa. Es normal. Observa más días.

**Si la pérdida es 10-25%:**
- ⚠️ Reduce riesgo (`RiskPercent = 0.5`)
- Continúa observando
- Contacta a Andrés

**Si la pérdida es > 25%:**
- ✗ DETÉN el robot
- ✓ Contacta a Andrés INMEDIATAMENTE
- Hay un problema serio

**Tiempo:** 5 minutos para evaluar, después contacta a Andrés

---

## Plan de Contacto de Emergencia

### Situación: CRÍTICA (Detén ahora)
- Pérdida > 25% en días
- Margen muy bajo (< 20%)
- Errores repetidos
- Conexión perdida > 1 hora

**Acción:**
1. DETÉN el robot (Opción A)
2. Captura pantalla del error / equity
3. Contacta a Andrés **INMEDIATAMENTE**
4. Proporciona:
   - Fecha y hora exacta
   - Captura pantalla del Journal
   - Equity actual
   - Última operación

**Tiempo de respuesta esperado:** < 2 horas

---

### Situación: IMPORTANTE (Dentro de 24 horas)
- Requotes frecuentes
- MaxDailyDrawdown activado
- Margen bajo (pero > 20%)
- Spreads anómalamente altos

**Acción:**
1. NO HAGAS CAMBIOS
2. Registra observaciones
3. Contacta a Andrés hoy
4. Proporciona:
   - Resumen de equity últimos 3 días
   - Parámetro que piensas cambiar
   - Journal de ayer

**Tiempo de respuesta esperado:** < 24 horas

---

### Situación: NORMAL (Puedo esperar)
- Operaciones perdedoras (es normal)
- Cambios pequeños en equity
- Robot funcionando sin errores

**Acción:**
1. ✓ Continúa monitoreando
2. Registra en tu tabla diaria
3. Reporta resultados semanales a Andrés (opcional)

---

## Checklist de Emergencia (Imprime Este)

**Guárdalo en tu escritorio o imprímelo.**

```
┌─────────────────────────────────────────────────────────┐
│ CHECKLIST DE EMERGENCIA – BB_BTC_EA_v8_1               │
├─────────────────────────────────────────────────────────┤
│ [ ] 1. DETÉN el robot (Herramientas → Opciones)        │
│ [ ] 2. Abre Journal (Ctrl+J)                           │
│ [ ] 3. Lee mensaje de error                            │
│ [ ] 4. Anota hora, fecha, error exacto                 │
│ [ ] 5. Captura pantalla (Print Screen)                 │
│ [ ] 6. ¿Es CRÍTICO? → Contacta a Andrés ahora         │
│ [ ] 7. ¿Es IMPORTANTE? → Contacta a Andrés hoy        │
│ [ ] 8. ¿Es NORMAL? → Continúa monitoreando            │
│ [ ] 9. Guardan captura en carpeta "Emergencias"        │
│ [ ] 10. Espera confirmación de Andrés antes de recargar│
└─────────────────────────────────────────────────────────┘
```

---

## No Hagas Esto (PROHIBIDO)

❌ **NO** hagas cambios manuales sin consultar
❌ **NO** cierres el robot sin detenerlo primero
❌ **NO** ignores mensajes de error
❌ **NO** aumentes mucho el riesgo de golpe
❌ **NO** intentes "recuperar pérdidas" aumentando parámetros
❌ **NO** dejes el robot sin monitoreo más de 1 día si hay problemas

---

## Resumen Rápido

| Problema | Acción Rápida | Tiempo |
|----------|---------------|--------|
| Robot rojo | Doble clic en gráfico | 10s |
| Requote | Aumentar SlippagePoints | 1min |
| Margen bajo | Cerrar posiciones o depositar | 5min |
| Drawdown máximo | Esperar a mañana 00:00 | 24h |
| Perdidas > 25% | DETÉN + Contacta Andrés | 5min + inmediato |
| Trading no permitido | Herramientas → Opciones → Permitir | 1min |
| Conexión perdida | Reinicia MetaTrader | 5min |

---

## Teléfono/Email de Emergencia

Contacta a Andrés:
- **Teléfono:** [agregará]
- **WhatsApp:** [agregará]
- **Email:** [agregará]

---

**Última actualización:** 18 de mayo de 2026  
**Versión:** 1.0  
**Verificado:** Andrés - Ingeniero de Sistemas
