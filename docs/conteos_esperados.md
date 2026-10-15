# Conteos esperados después de cada carga

Calculados aplicando la misma lógica de `sp_carga_inicial` y `sp_cargar` sobre el dataset (271,116 filas).
Después de cada carga, `bin/validar.sh <tipo>` debe mostrar **exactamente** estos números.
Después de cada restauración, los conteos deben coincidir con el paso que contiene ese respaldo.

## Carga por año (`olimpiadas_anio`)

| Paso | Respaldo que va después | pais | edicion | deporte | evento | deportista | participacion | resultado | bitacora_carga |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 · Carga inicial (países) | **FULL** | 230 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| 1 · Pekín 2008 (13,602 filas fuente) | DIFERENCIAL 1 | 231 | 1 | 34 | 302 | 10,899 | 10,899 | 13,602 | 2 |
| 2 · Londres 2012 (12,920) | DIFERENCIAL 2 | 231 | 2 | 34 | 319 | 17,835 | 21,416 | 26,522 | 3 |
| 3 · Río 2016 (13,688) | DIFERENCIAL 3 | 231 | 3 | 36 | 326 | 25,082 | 32,595 | 40,210 | 4 |

## Carga por deporte (`olimpiadas_deporte`) — 100 m planos femeninos

| Paso | Respaldo que va después | pais | edicion | deporte | evento | deportista | participacion | resultado | bitacora_carga |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 · Carga inicial (países) | **FULL** | 230 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| 1 · Pekín 2008 (85 filas fuente) | DIFERENCIAL 1 | 230 | 1 | 1 | 1 | 85 | 85 | 85 | 2 |
| 2 · Londres 2012 (79) | DIFERENCIAL 2 | 230 | 2 | 1 | 1 | 144 | 164 | 164 | 3 |
| 3 · Río 2016 (80) | DIFERENCIAL 3 | 230 | 3 | 1 | 1 | 200 | 244 | 244 | 4 |

## Carga por deportista (`olimpiadas_deportista`) — Usain Bolt

| Paso | Respaldo que va después | pais | edicion | deporte | evento | deportista | participacion | resultado | bitacora_carga |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 · Carga inicial (países) | **FULL** | 230 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| 1 · Atenas 2004 (1 fila fuente) | DIFERENCIAL 1 | 230 | 1 | 1 | 1 | 1 | 1 | 1 | 2 |
| 2 · Pekín 2008 (3) | DIFERENCIAL 2 | 230 | 2 | 1 | 3 | 1 | 2 | 4 | 3 |
| 3 · Londres 2012 (3) | DIFERENCIAL 3 | 230 | 3 | 1 | 3 | 1 | 3 | 7 | 4 |

## Notas

- En la carga por año, `pais` pasa de 230 a 231 porque Singapur aparece en los resultados con el código `SGP`, que no está en el catálogo de regiones. El procedimiento lo agrega automáticamente.
- Si una carga se ejecuta dos veces, no duplica datos (inserta 0 filas nuevas), pero sí agrega una fila a `bitacora_carga`. Si pasa, vuelvan a empezar ese tipo con `bin/preparar_bd.sh`.
- La columna **huella** de `validar.sql` (checksum del contenido de cada tabla) no tiene un valor esperado fijo. Lo que importa es que **sea igual** antes de borrar la base y después de restaurar el respaldo equivalente.
