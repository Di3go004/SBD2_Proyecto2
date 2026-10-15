# Proyecto 2 · SBD2 · Respaldo y restauración de bases de datos

Datos de los Juegos Olímpicos cargados en **SQL Server 2022** (Docker, almacenamiento persistente) en tres tipos de carga: **por año**, **por deporte** y **por deportista**. Después de cada carga se toma un **respaldo físico por consola**: completo después de la carga inicial y **diferencial** después de cada una de las 3 cargas siguientes. Luego se elimina la base, se restaura midiendo tiempos y se valida la integridad.

- Modelo entidad-relación: [`docs/modelo_er.md`](docs/modelo_er.md)
- Conteos esperados después de cada carga: [`docs/conteos_esperados.md`](docs/conteos_esperados.md)

---

## Requisitos

- **Docker Desktop** (Windows/Mac) o Docker Engine (Linux), con unos 2 GB de RAM libres para SQL Server.
- Una terminal **bash**. En Linux y Mac sirve la normal; en Windows usen **Git Bash** o **WSL**.
- `git` y `curl`.

---

## Parte 1 · Levantar la base de datos (Persona 1)

### 1. Preparar la carpeta

```bash
cp .env.example .env        # contraseña de SQL Server (pueden dejar la que viene)
chmod +x bin/*.sh           # en Windows/Git Bash se puede omitir y usar: bash bin/...
```

### 2. Descargar los datos (~36 MB)

```bash
bin/descargar_datos.sh
```

Quedan `datos/athlete_events.csv` (271,116 filas) y `datos/noc_regions.csv` (230 filas).

### 3. Levantar SQL Server

```bash
docker compose up -d
docker logs -f olimpiadas-sql      # esperar "SQL Server is now ready for client connections" y salir con Ctrl+C
bin/sql.sh validacion/00_version.sql
```

Si aparece la versión de SQL Server, la conexión funciona.

### 4. Cargar el staging (una sola vez)

```bash
bin/sql.sh ddl/01_staging.sql
```

Debe mostrar `athlete_events_raw = 271116` y `noc_regions_raw = 230`. Esta base (`olimpiadas_staging`) es solo la fuente y **no se respalda**.

### 5. Prueba rápida (con el tipo "anio")

```bash
bin/preparar_bd.sh anio     # crea olimpiadas_anio vacía con tablas y procedimientos
bin/cargar.sh anio 0        # carga inicial: 230 países
bin/validar.sh anio
bin/cargar.sh anio 1        # Pekín 2008
bin/validar.sh anio
```

Comparen los conteos con [`docs/conteos_esperados.md`](docs/conteos_esperados.md). Después de la carga 1 deben ver `deportista = 10899` y `resultado = 13602`.

### 6. Comprobar el almacenamiento persistente (lo pide el enunciado)

```bash
docker compose down         # SIN -v
docker compose up -d
# esperar unos segundos
bin/validar.sh anio         # deben salir los mismos conteos
```

Tomen captura de esto: es la evidencia de que los datos sobreviven al reinicio del contenedor.

### 7. Dejarlo listo para el grupo

```bash
git init && git add . && git commit -m "Base de datos, cargas y validacion"
# crear el repo en GitHub, hacer push y agregar a los compañeros
```

La prueba del paso 5 no cuenta como ejecución oficial. El ciclo oficial empieza otra vez con `bin/preparar_bd.sh`, que borra y recrea la base.

---

## Parte 2 · Ciclo oficial por tipo de carga

Se repite igual para `anio`, `deporte` y `deportista`. Las tres corridas deben hacerse **en la misma máquina**, para que los tiempos sean comparables. Capturas en cada paso, siempre con el reloj del sistema visible.

| # | Comando | Luego |
|---|---|---|
| 1 | `bin/preparar_bd.sh <tipo>` | base nueva y vacía |
| 2 | `bin/cargar.sh <tipo> 0` | `validar` + `ver_tablas` + capturas → **BACKUP FULL** |
| 3 | `bin/cargar.sh <tipo> 1` | `validar` + `ver_tablas` + capturas → **BACKUP DIFERENCIAL 1** |
| 4 | `bin/cargar.sh <tipo> 2` | `validar` + `ver_tablas` + capturas → **BACKUP DIFERENCIAL 2** |
| 5 | `bin/cargar.sh <tipo> 3` | `validar` + `ver_tablas` + capturas → **BACKUP DIFERENCIAL 3** |
| 6 | `bin/validar.sh <tipo>` | anotar las **huellas** finales → **DROP DATABASE** |
| 7 | Restaurar FULL | medir tiempo → `validar` (deben salir los conteos del paso 0) |
| 8 | Restaurar FULL + DIFF 1, luego FULL + DIFF 2, luego FULL + DIFF 3 | medir cada tiempo → `validar` cada vez |

Los scripts de respaldo y restauración van en `scripts/backup/` y `scripts/restauracion/` (Persona 2).

---

## Estructura

```
bin/                    comandos para la terminal (todos guardan su salida en logs/)
  sql.sh                ejecuta cualquier .sql dentro del contenedor
  descargar_datos.sh    descarga los CSV
  preparar_bd.sh        crea la base de un tipo desde cero
  cargar.sh             ejecuta la carga 0..3 de un tipo
  validar.sh            conteos, huellas, bitácora, fragmentación, DBCC CHECKDB
  ver_tablas.sh         SELECT * de todas las tablas
scripts/
  ddl/                  staging, creación de base, tablas, procedimientos
  carga/                carga inicial y cargas por año / deporte / deportista
  validacion/           consultas de validación
  backup/               (Persona 2) respaldos completos y diferenciales
  restauracion/         (Persona 2) eliminación y restauraciones
docs/                   modelo ER y conteos esperados
capturas/               evidencias por tipo de carga
logs/                   salida de cada comando, con fecha y hora
respaldos/              archivos .bak (no se suben a git)
datos/                  CSV de entrada (no se suben a git)
```

---

## Problemas comunes

- **`Login failed for user 'sa'`**: la contraseña se fija la *primera* vez que arranca el contenedor. Si después cambiaron `.env`, vuelvan a la contraseña original. También puede pasar que la contraseña no cumpla la complejidad mínima: 8 o más caracteres con mayúsculas, minúsculas y números.
- **`Cannot bulk load ... could not be opened`**: faltan los CSV en `datos/`. Corran `bin/descargar_datos.sh` y luego `docker compose up -d --force-recreate`.
- **Windows: `$'\r': command not found`**: los `.sh` quedaron con fin de línea de Windows. El archivo `.gitattributes` lo evita al clonar. Si ya pasó, ejecuten `sed -i 's/\r$//' bin/*.sh`.
- **Mac con chip M**: el primer arranque es lento porque corre emulado. Si el contenedor se detiene solo, activen en Docker Desktop la opción *Use Rosetta for x86_64/amd64 emulation*.
- **Puerto 1433 ocupado**: cambien `"1433:1433"` por `"1434:1433"` en `docker-compose.yml`. Los scripts no usan el puerto, porque se conectan desde dentro del contenedor.
- **No usar `docker compose down -v`**: borra el volumen con todas las bases.

## Fuente de datos

"120 years of Olympic history: athletes and results" (Randi Griffin, Kaggle, datos de sports-reference.com), cubre de Atenas 1896 a Río 2016. Se descarga de la copia pública de TidyTuesday en GitHub (`rfordatascience/tidytuesday`, 2021-07-27).
