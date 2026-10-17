# Tabla de tiempos y tamaños

Los valores de esta tabla se transcribieron de los logs oficiales del 16 de octubre de 2026. El escenario `FULL + DIFF N` restaura el FULL con `NORECOVERY` y el diferencial N con `RECOVERY`; por eso su tiempo total es la suma de ambos mensajes `RESTORE DATABASE successfully processed ... seconds`.

## Resultados de restauración

| Tipo | Escenario | FULL (MB) | DIFF (MB) | Total restaurado (MB) | Tiempo total (s) | Conteos | Huellas |
|---|---|---:|---:|---:|---:|---|---|
| Por año | Solo FULL | 4.02 | — | 4.02 | 0.095 | OK | OK |
| Por año | FULL + DIFF 1 | 4.02 | 4.65 | 8.67 | 0.287 | OK | OK |
| Por año | FULL + DIFF 2 | 4.02 | 8.09 | 12.11 | 0.157 | OK | OK |
| Por año | FULL + DIFF 3 | 4.02 | 10.09 | 14.11 | 0.154 | OK | OK |
| Por deporte | Solo FULL | 4.02 | — | 4.02 | 0.088 | OK | OK |
| Por deporte | FULL + DIFF 1 | 4.02 | 2.84 | 6.86 | 0.169 | OK | OK |
| Por deporte | FULL + DIFF 2 | 4.02 | 3.02 | 7.04 | 0.168 | OK | OK |
| Por deporte | FULL + DIFF 3 | 4.02 | 3.02 | 7.04 | 0.156 | OK | OK |
| Por deportista | Solo FULL | 4.02 | — | 4.02 | 0.085 | OK | OK |
| Por deportista | FULL + DIFF 1 | 4.02 | 2.46 | 6.48 | 0.176 | OK | OK |
| Por deportista | FULL + DIFF 2 | 4.02 | 2.46 | 6.48 | 0.210 | OK | OK |
| Por deportista | FULL + DIFF 3 | 4.02 | 2.46 | 6.48 | 0.175 | OK | OK |

La versión editable completa está en [`tabla_tiempos.csv`](tabla_tiempos.csv). Los logs usados están indicados en sus dos últimas columnas.

## Estados restaurados

| Tipo | FULL | DIFF 1 | DIFF 2 | DIFF 3 |
|---|---|---|---|---|
| Por año | 230 países, 0 resultados | 13,602 resultados | 26,522 resultados | 40,210 resultados |
| Por deporte | 230 países, 0 resultados | 85 resultados | 164 resultados | 244 resultados |
| Por deportista | 230 países, 0 resultados | 1 resultado | 4 resultados | 7 resultados |

En los doce escenarios los conteos coinciden con `docs/conteos_esperados.md`, las huellas coinciden con la ejecución previa al `DROP DATABASE` y `DBCC CHECKDB` termina sin errores.

## Criterio para la ejecución por año

Hay un intento adicional de restauración de `FULL + DIFF 3` en `logs/20261016_180304_restaurar_diferencial_master.log`. Para la tabla oficial se usa la ejecución de `18:03:23`, que es la que quedó seguida por el `DROP`, la restauración y la validación final de `18:03:25`.
