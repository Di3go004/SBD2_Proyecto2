# Manual de usuario

## Proyecto 2 — SBD2

Este manual explica cómo preparar el entorno, cargar los datos olímpicos, crear respaldos, eliminar y restaurar cada base, validar los resultados y leer los logs. Todos los comandos se ejecutan desde la raíz del repositorio.

El proyecto usa SQL Server 2022 Developer dentro de Docker. Hay tres bases de trabajo:

- `olimpiadas_anio`: cargas completas de Pekín 2008, Londres 2012 y Río 2016.
- `olimpiadas_deporte`: evento `Athletics Women's 100 metres` en 2008, 2012 y 2016.
- `olimpiadas_deportista`: Usain Bolt en Atenas 2004, Pekín 2008 y Londres 2012.

## 1. Requisitos

- Docker Desktop activo en Windows o Docker Engine en Linux.
- Git y `curl`.
- Git Bash o WSL en Windows; los scripts tienen formato Bash.
- Al menos 2 GB libres para SQL Server y espacio adicional para el dataset.

No se deben ejecutar los respaldos desde SSMS o DBeaver. El procedimiento oficial se ejecuta por terminal para que cada acción quede registrada en `logs/`.

## 2. Preparar el entorno

### 2.1 Clonar y configurar la contraseña

```bash
git clone https://github.com/Di3go004/SBD2_Proyecto2.git
cd SBD2_Proyecto2
cp .env.example .env
```

La contraseña de `SA_PASSWORD` debe tener al menos ocho caracteres, mayúsculas, minúsculas y números. La contraseña se fija la primera vez que se inicializa el volumen de SQL Server. Si se cambia `.env` después, el contenedor conservará la contraseña original.

En Git Bash se pueden habilitar los scripts con:

```bash
chmod +x bin/*.sh
```

### 2.2 Descargar los CSV

```bash
bin/descargar_datos.sh
```

La salida debe indicar 271,117 líneas para `athlete_events.csv` y 231 líneas para `noc_regions.csv`; las líneas incluyen el encabezado. Los CSV se guardan en `datos/` y no se suben al repositorio.

### 2.3 Levantar SQL Server

```bash
docker compose up -d
docker logs -f olimpiadas-sql
```

Cuando aparezca `SQL Server is now ready for client connections`, salir del seguimiento con `Ctrl+C`. El contenedor puede seguir ejecutándose.

Comprobar la versión:

```bash
bin/sql.sh validacion/00_version.sql
```

El script `bin/sql.sh` ejecuta el SQL dentro del contenedor y guarda la salida completa en un log con el formato:

```text
logs/AAAAMMDD_HHMMSS_<operacion>_<base>.log
```

### 2.4 Cargar staging

```bash
bin/sql.sh ddl/01_staging.sql
```

La salida correcta es:

```text
athlete_events_raw|271116|271116
noc_regions_raw|230|230
```

La base `olimpiadas_staging` es una fuente de lectura y no forma parte de los respaldos oficiales.

## 3. Preparar una base de carga

Cada tipo usa una base separada. El comando siguiente elimina la base del tipo si ya existe y la recrea con tablas, restricciones y procedimientos:

```bash
bin/preparar_bd.sh anio
bin/preparar_bd.sh deporte
bin/preparar_bd.sh deportista
```

Ejecutar solo el tipo que se va a trabajar. El script pide confirmación porque elimina la base existente. Responder `s`.

No se debe usar `docker compose down -v` para reiniciar el contenedor: esa opción elimina el volumen `mssql_data` y borra las bases.

## 4. Cargas y validación

### 4.1 Carga inicial

La carga cero inserta los 230 países del catálogo:

```bash
bin/cargar.sh anio 0
bin/validar.sh anio
bin/ver_tablas.sh anio
```

Para los otros tipos se cambia `anio` por `deporte` o `deportista`. Después de esta carga se crea el respaldo FULL.

### 4.2 Cargas específicas

Después de cada carga se ejecutan validación y, si se necesita evidencia detallada, `ver_tablas.sh`:

```bash
bin/cargar.sh anio 1
bin/validar.sh anio
bin/ver_tablas.sh anio

bin/cargar.sh anio 2
bin/validar.sh anio

bin/cargar.sh anio 3
bin/validar.sh anio
```

Los equivalentes son:

```bash
bin/cargar.sh deporte 1
bin/cargar.sh deporte 2
bin/cargar.sh deporte 3

bin/cargar.sh deportista 1
bin/cargar.sh deportista 2
bin/cargar.sh deportista 3
```

Los conteos esperados completos están en [`conteos_esperados.md`](conteos_esperados.md). Los valores finales son:

| Tipo | Países | Ediciones | Deportistas | Participaciones | Resultados |
|---|---:|---:|---:|---:|---:|
| Por año | 231 | 3 | 25,082 | 32,595 | 40,210 |
| Por deporte | 230 | 3 | 200 | 244 | 244 |
| Por deportista | 230 | 3 | 1 | 3 | 7 |

La carga por año termina con 231 países porque el dataset contiene `SGP` y ese código no estaba en el catálogo inicial; el procedimiento lo agrega automáticamente.

## 5. Respaldo completo y diferenciales

El respaldo FULL se ejecuta inmediatamente después de validar la carga 0:

```bash
bin/sql.sh backup/backup_full.sql master TIPO=anio
```

El archivo queda en `respaldos/anio_0_full.bak`. Para otro tipo se cambia `TIPO`.

Después de cada carga 1, 2 y 3 se crea un diferencial:

```bash
bin/sql.sh backup/backup_diferencial.sql master TIPO=anio N=1
bin/sql.sh backup/backup_diferencial.sql master TIPO=anio N=2
bin/sql.sh backup/backup_diferencial.sql master TIPO=anio N=3
```

Los nombres son `anio_1_diff.bak`, `anio_2_diff.bak` y `anio_3_diff.bak`. El script usa `CHECKSUM` y ejecuta `RESTORE VERIFYONLY`; si la verificación falla, no se debe continuar con la evidencia de ese respaldo.

Para consultar el historial registrado por SQL Server:

```bash
bin/sql.sh backup/listar_respaldos.sql msdb
ls -lh respaldos/
```

La consulta muestra base de datos, tipo, inicio, fin, duración, tamaño en MB y ruta del archivo.

## 6. Eliminar y restaurar

Antes de eliminar la base, ejecutar una última validación y conservar las huellas:

```bash
bin/validar.sh anio
bin/sql.sh restauracion/eliminar_bd.sql master TIPO=anio
```

El script fuerza `SINGLE_USER`, revierte conexiones activas y ejecuta `DROP DATABASE`.

### 6.1 Restaurar solo el FULL

```bash
bin/sql.sh restauracion/restaurar_full.sql master TIPO=anio
bin/validar.sh anio
```

El estado debe contener únicamente la carga inicial: 230 países y cero resultados.

### 6.2 Restaurar FULL más un diferencial

Para cada diferencial se elimina la base antes de volver a restaurar:

```bash
bin/sql.sh restauracion/eliminar_bd.sql master TIPO=anio
bin/sql.sh restauracion/restaurar_diferencial.sql master TIPO=anio N=1
bin/validar.sh anio

bin/sql.sh restauracion/eliminar_bd.sql master TIPO=anio
bin/sql.sh restauracion/restaurar_diferencial.sql master TIPO=anio N=2
bin/validar.sh anio

bin/sql.sh restauracion/eliminar_bd.sql master TIPO=anio
bin/sql.sh restauracion/restaurar_diferencial.sql master TIPO=anio N=3
bin/validar.sh anio
```

El diferencial de SQL Server es acumulativo desde el FULL. Por eso no se aplican DIFF 1, DIFF 2 y DIFF 3 en cadena: para recuperar el estado 3 basta el FULL y DIFF 3.

## 7. Cómo validar una restauración

`bin/validar.sh <tipo>` ejecuta cinco comprobaciones:

1. Base de datos y fecha/hora del servidor.
2. Conteo de filas por tabla.
3. Huella con `CHECKSUM_AGG(BINARY_CHECKSUM(*))`.
4. Fragmentación de índices y cantidad de páginas.
5. `DBCC CHECKDB`.

La huella se usa como comprobación de igualdad entre dos ejecuciones; no debe llamarse hash criptográfico. La salida correcta termina con:

```text
DBCC CHECKDB terminado sin errores.
```

La restauración es válida cuando los conteos corresponden al respaldo aplicado y las huellas coinciden con la validación previa al `DROP DATABASE`.

## 8. Cómo leer los logs

Cada ejecución de `bin/sql.sh` genera un archivo con inicio y fin:

```text
=== INICIO 2026-10-16 19:23:14 | ... ===
...
=== FIN    2026-10-16 19:23:17 ===
```

Para localizar operaciones en Git Bash:

```bash
grep -nE "BACKUP|RESTORE|processed|CHECKDB|ERROR|The backup set" logs/*.log
```

Los mensajes más importantes son:

- `The backup set on file 1 is valid`: `RESTORE VERIFYONLY` aprobó el archivo.
- `BACKUP DATABASE successfully processed`: el respaldo terminó.
- `RESTORE DATABASE successfully processed ... seconds`: páginas y tiempo de restauración.
- `DBCC CHECKDB terminado sin errores`: integridad física comprobada.
- `ERROR`, `Msg` o ausencia de la línea `FIN`: revisar el comando antes de usar esa evidencia.

El archivo `logs/README.md` describe las familias de logs. Para la tabla oficial de tiempos se usan únicamente los logs de los ciclos del 16 de octubre de 2026; los logs del 14 de octubre corresponden a la prueba inicial.

## 9. Persistencia del volumen

Para verificar que los datos sobreviven al reinicio del contenedor:

```bash
bin/validar.sh anio
docker compose down
docker compose up -d
# esperar a que SQL Server acepte conexiones
bin/validar.sh anio
```

Los conteos y huellas deben permanecer iguales. Nunca agregar `-v` a `docker compose down`.

## 10. Problemas frecuentes

### Login fallido

Verificar que `.env` existe y que la contraseña coincide con la usada al inicializar el volumen. Si la contraseña original se perdió, la recuperación requiere eliminar el volumen, lo cual destruye los datos locales y no debe hacerse sobre la evidencia oficial.

### No se puede abrir el CSV

Ejecutar `bin/descargar_datos.sh` y comprobar que existen `datos/athlete_events.csv` y `datos/noc_regions.csv`. Después recrear el contenedor con `docker compose up -d --force-recreate`.

### Puerto 1433 ocupado

Cambiar el puerto del host en `docker-compose.yml`, por ejemplo de `1433:1433` a `1434:1433`. Los scripts ejecutan `sqlcmd` dentro del contenedor y no dependen del puerto del host.

### Restauración bloqueada

Cerrar conexiones en SSMS/DBeaver y ejecutar primero `restauracion/eliminar_bd.sql`; el script aplica `SINGLE_USER WITH ROLLBACK IMMEDIATE`.

## 11. Checklist operativo

- [ ] `.env` creado y contraseña válida.
- [ ] CSV descargados y conteos de staging correctos.
- [ ] SQL Server listo y versión registrada.
- [ ] Base preparada desde cero para cada tipo.
- [ ] Carga 0 y tres cargas específicas validadas.
- [ ] Un FULL y tres diferenciales por tipo.
- [ ] Lista de respaldos guardada.
- [ ] Huellas guardadas antes del DROP.
- [ ] FULL y FULL + cada DIFF restaurados.
- [ ] Conteos, huellas y `DBCC CHECKDB` correctos después de cada restauración.
- [ ] Capturas con reloj visible.
- [ ] Logs y comentarios revisados antes de entregar.

## 12. Fuente de datos

El dataset es **120 years of Olympic history: athletes and results**, publicado originalmente por Randi Griffin a partir de datos de sports-reference.com. El proyecto descarga la copia pública de TidyTuesday del 27 de julio de 2021:

<https://github.com/rfordatascience/tidytuesday/tree/master/data/2021/2021-07-27>
