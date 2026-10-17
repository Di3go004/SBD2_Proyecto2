# Plan Proyecto 2 SBD2 — Respaldo y Restauración

14 de octubre de 2026 · Diego

## Resumen y decisiones

Entregamos el **sábado 17 de octubre**. Cargamos datos olímpicos en SQL Server (Docker) en 3 tipos de carga, respaldamos después de cada carga, borramos la base, la restauramos midiendo tiempos y comparamos las estrategias.

| Decisión | Qué elegimos | Por qué |
| --- | --- | --- |
| Motor | SQL Server 2022 Developer en Docker, con volumen persistente | Respaldo físico nativo por consola (`BACKUP` / `RESTORE`); al restaurar imprime el tiempo |
| Estrategia | FULL después de la carga inicial + DIFERENCIAL después de cada carga 1, 2 y 3 | El enunciado deja elegir incremental o diferencial según el motor; SQL Server trae diferencial nativo |
| Datos | "120 years of Olympic history": 271,116 filas, de 1896 a Río 2016 | Público; se descarga con un comando |
| Carga inicial | Catálogo de 230 países (igual en los 3 tipos) | Base mínima para el respaldo FULL |
| Por año | Pekín 2008, Londres 2012, Río 2016 | Unas 13,000 filas cada una |
| Por deporte | 100 m planos femeninos en 2008, 2012 y 2016 | Ejemplo del enunciado |
| Por deportista | Usain Bolt en Atenas 2004, Pekín 2008 y Londres 2012 | Ejemplo exacto del enunciado |

En total quedan 3 respaldos FULL y 9 diferenciales: 1 + 3 por tipo, más de lo que pide la rúbrica.

Preguntas abiertas para el auxiliar:

- ¿A qué hora cierra la entrega del sábado?
- ¿Confirma que la carga inicial puede ser el catálogo de países, seguida de 3 cargas con su diferencial?

## Estado del proyecto

La base de datos ya funciona. La prueba de carga dio exactamente los conteos esperados y los datos sobrevivieron al reinicio del contenedor, así que el jueves Persona 2 puede empezar con los respaldos.

### Ya hecho (Persona 1, miércoles 14)

| Qué | Resultado | Evidencia |
| --- | --- | --- |
| Repo `SBD2_Proyecto2` con el kit | Docker, scripts por tipo (ddl, carga, validación), modelo ER, conteos esperados | El repo en GitHub |
| SQL Server en Docker | SQL Server 2022 Developer 16.0.4305.5, con volumen persistente | `logs/…_00_version_master.log` |
| Staging | 271,116 resultados y 230 países cargados desde CSV | `logs/…_01_staging_master.log` |
| Modelo y procedimientos de carga | 7 tablas normalizadas + bitácora; cargas por año, deporte y deportista | `scripts/ddl/` |
| Prueba de carga 0 y 1 (por año) | 230 países, luego 10,899 deportistas y 13,602 resultados, igual a lo esperado; DBCC CHECKDB sin errores | `logs/…_validar_olimpiadas_anio.log` |
| Persistencia de Docker | Mismos conteos y mismas huellas antes y después de `docker compose down` / `up` | `capturas/persistencia/Captura Persistencia.png` |

Esa prueba no cuenta como ejecución oficial. El ciclo oficial empieza otra vez con `bin/preparar_bd.sh`.

### Seguimiento de tareas

| Tarea | Responsable | Día | Estado |
| --- | --- | --- | --- |
| Entorno, staging, modelo, cargas y validación | Persona 1 | Mié 14 | Hecho |
| Captura de persistencia y push del repo | Persona 1 | Mié 14 | Hecho |
| Agregar a Persona 2 y 3 como colaboradores en GitHub | Persona 1 | Mié 14 | Pendiente de confirmar en GitHub |
| Clonar el repo y levantar el entorno (ver abajo) | Persona 2 | Jue 15 temprano | Hecho |
| Scripts de BACKUP FULL, diferencial y listado de respaldos | Persona 2 | Jue 15 | Hecho |
| Scripts de DROP y restauraciones | Persona 2 | Jue 15 | Hecho |
| Ciclo oficial por año | Persona 2 | Jue 15 noche | Hecho |
| Ciclo oficial por deporte | Persona 2 | Vie 16 | Hecho |
| Ciclo oficial por deportista | Persona 2 | Sáb 17 temprano | Hecho |
| Manual de usuario: respaldos, restauración, lectura de logs | Persona 2 | Vie 16 | Hecho |
| Diagrama ER exportado y diccionario de datos | Persona 1 | Jue 15 | Hecho |
| Manual de usuario: instalación, carga y validación | Persona 1 | Vie 16 | Hecho |
| Esqueleto del PDF, metodología y plan de respaldo | Persona 3 | Jue 15 | Hecho |
| Especificaciones del servidor (máquina de Persona 2) | Persona 3 | Jue 15 | Hecho con configuración referencial explícitamente no verificada |
| Tabla de tiempos, gráficos y fragmentación | Persona 3 | Vie 16 – Sáb 17 | Hecho |
| Conclusiones y PDF final | Persona 3 | Sáb 17 | Hecho, sujeto a completar la ficha del servidor |
| Entrega en UEDI, los tres integrantes | Todos | Sáb 17 | Pendiente |

### Cómo arrancan Persona 2 y Persona 3

Pidan a Persona 1 acceso al repo. Después, en una terminal bash (Linux o Mac; Git Bash o WSL en Windows), con Docker Desktop abierto:

```bash
git clone https://github.com/<usuario-de-persona-1>/SBD2_Proyecto2.git
cd SBD2_Proyecto2
cp .env.example .env
bin/descargar_datos.sh          # debe decir 271117 y 231 líneas
docker compose up -d            # luego esperar unos 30 segundos
bin/sql.sh ddl/01_staging.sql   # debe mostrar 271116 y 230
```

Si ese último comando muestra los dos conteos, el entorno quedó igual al de Persona 1. Persona 3 no necesita Docker: trabaja con los logs, las capturas y la tabla de tiempos que deja Persona 2.

## Reparto de roles

Cada persona responde por unos 30 de los 100 puntos de la rúbrica. Persona 1 (Diego) deja el repositorio listo para que los demás empiecen con `git clone` y tres comandos.

| Persona | Rol | Tareas | Entrega | Rúbrica |
| --- | --- | --- | --- | --- |
| Persona 1 | Base de datos y carga | Docker con volumen persistente; staging; modelo ER; tablas; procedimientos de carga; validación (conteos, huellas, fragmentación); repo en GitHub | Repo listo (hecho el miércoles 14); ER y diccionario de datos para el manual técnico; secciones de instalación, carga y validación del manual de usuario | 2.1 Carga masiva (15) + parte de 1.3 Código (15) |
| Persona 2 | Respaldos y restauración | Scripts de FULL, diferencial, listado de respaldos, DROP y restauraciones; **ejecuta los 3 ciclos oficiales en su máquina** y toma las capturas | Carpetas `scripts/backup` y `scripts/restauracion`, capturas, logs; secciones de respaldo, restauración y lectura de logs del manual de usuario | 2.2 Respaldos (15) + 2.3 Restauración (15) + parte de 1.2 Manual (10) |
| Persona 3 | Análisis y documentación | Especificaciones del servidor (la máquina de Persona 2); tabla de tiempos; gráficos; análisis de fragmentación; conclusiones; arma el PDF final | Manual técnico completo en PDF; opcionales si sobra tiempo (compresión, cifrado, cron) | 1.1 Documentación técnica (15) + 2.4 Análisis comparativo (15) |

Los 3 ciclos se ejecutan **en la misma máquina**. Si no, los tiempos de restauración no son comparables.

## Cronograma

**El repo quedó listo el miércoles; el jueves empiezan los respaldos.** Un tipo de carga por día, los 3 en la máquina de Persona 2.

| | Mié 14 (noche) | Jue 15 | Vie 16 | Sáb 17 · entrega |
| --- | --- | --- | --- | --- |
| **Persona 1** · Base de datos y carga | Docker + datos; staging cargado; prueba de carga 1; prueba de persistencia | **Repo ya listo**; modelo ER y diccionario; apoya a Persona 2 | Revisa conteos vs esperados; manual de usuario: carga y validación | Repo final; revisa checklist; entrega en UEDI |
| **Persona 2** · Respaldos | Instala Docker; prueba SQL Server; lee los comandos de este plan | Scripts de backup y restauración; **ciclo por año** completo (noche) | **Ciclo por deporte** completo; manual de usuario: respaldos y logs | **Ciclo por deportista** (30 min); entrega en UEDI |
| **Persona 3** · Análisis y documentación | Esqueleto del PDF; plantilla de specs del servidor | Metodología y plan de respaldo; specs de la máquina de Persona 2 | Gráficos de año y deporte; fragmentación; tabla comparativa | Gráficos finales; conclusiones; arma el PDF; entrega en UEDI |

Persona 2 corre un ciclo por día y Persona 3 analiza los tiempos del día anterior. Si algo se atrasa, el ciclo por deportista, que es el más corto, puede correr el viernes en la noche.

## Ciclo oficial por tipo de carga

Los tres tipos (`anio`, `deporte`, `deportista`) siguen los mismos 9 pasos, un tipo por día. Cada validación se compara con `docs/conteos_esperados.md` del repo.

1. `bin/preparar_bd.sh <tipo>`: crea la base nueva y vacía.
2. `bin/cargar.sh <tipo> 0` (230 países) → `bin/validar.sh <tipo>` + `bin/ver_tablas.sh <tipo>` + capturas → **BACKUP FULL** + captura.
3. `bin/cargar.sh <tipo> 1` → validar + capturas → **DIFERENCIAL 1** + captura.
4. `bin/cargar.sh <tipo> 2` → validar + capturas → **DIFERENCIAL 2** + captura.
5. `bin/cargar.sh <tipo> 3` → validar + capturas → **DIFERENCIAL 3** + captura.
6. Listar los respaldos desde `msdb` (fecha, tipo, tamaño, archivo) y `ls -lh respaldos/` → captura.
7. `bin/validar.sh <tipo>`: copiar las **huellas** finales → **DROP DATABASE** → captura donde se vea que la base ya no existe.
8. Restaurar solo el FULL → anotar el tiempo → validar (deben salir los conteos del paso 0).
9. Restaurar FULL + DIFF 1, luego FULL + DIFF 2, luego FULL + DIFF 3 → anotar cada tiempo → validar cada vez.
    - Después de FULL + DIFF 3, las huellas deben ser idénticas a las del paso 7. Esa es la prueba de que no se perdió ningún dato.

## Comandos base para Persona 2

Todo el respaldo y la restauración se hace con `BACKUP` / `RESTORE` por consola. Cada acción va en su `.sql` dentro de `scripts/backup` o `scripts/restauracion` y se corre con `bin/sql.sh <archivo> master`. Usen variables sqlcmd `$(TIPO)` y `$(N)` para tener un solo script por acción.

```sql
-- FULL después de la carga inicial
BACKUP DATABASE olimpiadas_anio
  TO DISK = N'/var/opt/mssql/respaldos/anio_0_full.bak'
  WITH INIT, CHECKSUM, STATS = 25;

-- DIFERENCIAL después de la carga N (1, 2 o 3)
BACKUP DATABASE olimpiadas_anio
  TO DISK = N'/var/opt/mssql/respaldos/anio_1_diff.bak'
  WITH DIFFERENTIAL, INIT, CHECKSUM, STATS = 25;

-- Comprobar que el archivo se puede leer
RESTORE VERIFYONLY
  FROM DISK = N'/var/opt/mssql/respaldos/anio_1_diff.bak' WITH CHECKSUM;

-- Listar respaldos: tipo D = full, I = diferencial
SELECT b.database_name, b.type, b.backup_start_date, b.backup_finish_date,
       CAST(b.backup_size / 1048576.0 AS DECIMAL(10, 2)) AS tamano_mb,
       m.physical_device_name
FROM msdb.dbo.backupset AS b
JOIN msdb.dbo.backupmediafamily AS m ON m.media_set_id = b.media_set_id
WHERE b.database_name LIKE 'olimpiadas_%'
ORDER BY b.backup_start_date;

-- Eliminar la base
ALTER DATABASE olimpiadas_anio SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE olimpiadas_anio;

-- Restaurar solo el FULL
RESTORE DATABASE olimpiadas_anio
  FROM DISK = N'/var/opt/mssql/respaldos/anio_0_full.bak'
  WITH REPLACE, RECOVERY, STATS = 25;

-- Restaurar FULL + DIFERENCIAL N
RESTORE DATABASE olimpiadas_anio
  FROM DISK = N'/var/opt/mssql/respaldos/anio_0_full.bak'
  WITH REPLACE, NORECOVERY, STATS = 25;
RESTORE DATABASE olimpiadas_anio
  FROM DISK = N'/var/opt/mssql/respaldos/anio_3_diff.bak'
  WITH RECOVERY, STATS = 25;
```

- **Tiempo de restauración**: cada `RESTORE` imprime "processed N pages in X seconds". Anoten X. En FULL + DIFF el tiempo es la suma de los dos `RESTORE`. El log de `bin/sql.sh` guarda además la hora de inicio y fin.
- **Diferencial frente a incremental**: el diferencial guarda todo lo que cambió desde el FULL, así que para restaurar basta FULL + el último. Un incremental necesita FULL + todos en orden. Esa diferencia es el centro del análisis.
- Antes de restaurar, cierren cualquier SSMS o DBeaver conectado a esa base, porque `RESTORE` necesita acceso exclusivo.

## Tiempos y análisis (Persona 3)

Persona 2 llena esta tabla mientras ejecuta cada ciclo. Persona 3 la convierte en los gráficos y la tabla comparativa del manual técnico.

| Tipo | Restauración | Tamaño de los .bak (MB) | Tiempo RESTORE (s) | Conteos OK | Huellas OK |
| --- | --- | --- | --- | --- | --- |
| Por año | Solo FULL | | | | |
| Por año | FULL + DIFF 1 | | | | |
| Por año | FULL + DIFF 2 | | | | |
| Por año | FULL + DIFF 3 | | | | |
| Por deporte | Solo FULL | | | | |
| Por deporte | FULL + DIFF 1 | | | | |
| Por deporte | FULL + DIFF 2 | | | | |
| Por deporte | FULL + DIFF 3 | | | | |
| Por deportista | Solo FULL | | | | |
| Por deportista | FULL + DIFF 1 | | | | |
| Por deportista | FULL + DIFF 2 | | | | |
| Por deportista | FULL + DIFF 3 | | | | |

Qué debe cubrir el análisis:

- **Gráficos**: tiempo de restauración por escenario, agrupado por tipo de carga; tamaño de cada diferencial frente a las filas cargadas.
- **Diferencial acumulativo**: cada diferencial debería pesar más que el anterior. Expliquen por qué y qué pasaría con un incremental, que necesita restaurar todos los respaldos en orden.
- **Volumen**: la carga por año mueve unas 40,000 filas; deporte y deportista, menos de 250. Si los tiempos casi no cambian en los dos últimos, explíquenlo como el costo fijo de cada `RESTORE`.
- **Fragmentación**: comparen el `fragmentacion_pct` de `bin/validar.sh` entre cargas. En tablas de pocas páginas el porcentaje no es representativo.
- **Especificaciones del servidor**: CPU, RAM, disco, sistema operativo, RAM asignada a Docker y la salida de `@@VERSION`.
- **Recomendación final** sustentada con los números de la tabla, no con teoría general.

Opcionales, solo si sobra tiempo: `WITH COMPRESSION` (comparar tamaño y tiempo), cifrado con certificado (`WITH ENCRYPTION`), un script para cron y una alerta que compare las huellas después de restaurar.

## Convenciones

- **Capturas**: todas con el reloj del sistema operativo visible. Si no, corran `date` justo antes. Van en `capturas/<tipo>/` con nombres como `1_carga_validar.png` o `r3_restore_diff.png` (detalle en `capturas/LEEME.md`). La de persistencia va en `capturas/persistencia/`.
- **Respaldos**: `<tipo>_0_full.bak` y `<tipo>_<n>_diff.bak` en `respaldos/`. No se suben a git; se documentan con capturas y con el listado de `msdb`.
- **Logs**: cada comando de `bin/` guarda su salida con fecha y hora en `logs/`. Se suben al repo y Persona 2 agrega un comentario corto a los del ciclo oficial (el enunciado pide "logs de ejecución comentados").
- **Comandos**: todo por terminal. SSMS o DBeaver solo para mirar resultados, nunca para respaldar ni restaurar.
- **Git**: cada quien trabaja en su carpeta (`scripts/backup`, `scripts/restauracion`, `docs/`) para no pisarse.

## Checklist de entrega

Si falta cualquiera de los primeros siete puntos, la nota es **cero**, aunque todo lo demás funcione (sección 8.1 del enunciado).

- [ ] Todos los archivos y evidencias entregados antes de la hora límite del sábado 17
- [x] Los 3 ciclos completos: cargas, respaldos y restauraciones funcionando
- [x] Nada copiado sin referencia; el dataset y cualquier fuente, citados en el PDF
- [x] Manual técnico en PDF: metodología, modelo ER, plan de respaldo, ficha referencial del servidor, análisis con gráficos y conclusiones (hardware exacto no verificado)
- [x] Manual de usuario: cada tipo de backup, cómo restaurar, cómo leer los logs, cómo validar
- [x] Repositorio ordenado por tipo (`ddl`, `carga`, `backup`, `restauracion`, `validacion`) con logs comentados
- [ ] **Los tres** integrantes suben la entrega en UEDI
- [x] Captura de la prueba de persistencia: `docker compose down` / `up` con los mismos conteos
- [x] Capturas de cada carga y cada restauración con fecha y hora visibles
- [x] Tabla de tiempos completa y huellas iguales antes del DROP y después de FULL + DIFF 3

La plataforma general queda confirmada por el handover: Windows 11 de 64 bits, SSD NVMe M.2 y Docker Desktop con WSL2. El manual incluye una configuración referencial —Intel Core i5 o equivalente, 16 GB de RAM y 4 GB para Docker— marcada explícitamente como no verificada. El script `bin/registrar_especificaciones.ps1` permite sustituirla por valores medidos si se obtiene acceso a la máquina de Persona 2.
