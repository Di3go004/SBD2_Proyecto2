# Manual de Usuario — Administración de Respaldos y Recuperación
**Proyecto 2 — Sistemas de Bases de Datos 2 (USAC 2026)**

Este manual detalla los procedimientos operativos para respaldar y recuperar bases de datos en SQL Server 2022 mediante consola, garantizando la continuidad operativa y la integridad de la información.

---

## 1. Procedimiento de Respaldo Físico (Línea de Comandos)

Los respaldos se realizan mediante scripts T-SQL ejecutados a través del script envolvente `bin/sql.sh`.

### A. Respaldo Completo (Full Backup)
Se ejecuta tras completar la carga inicial de catálogos:
```bash
./bin/sql.sh backup/backup_full.sql master TIPO=<tipo>
```
*Parámetros:*
- `TIPO`: Identificador de la base de datos (`anio`, `deporte`, `deportista`).

*Acción interna:*
Genera el archivo en `/var/opt/mssql/respaldos/<tipo>_0_full.bak`, reinicia el medio con `INIT` y valida la integridad de lectura con `RESTORE VERIFYONLY`.

### B. Respaldo Diferencial
Se ejecuta tras cada lote incremental de datos (cargas 1, 2 o 3):
```bash
./bin/sql.sh backup/backup_diferencial.sql master TIPO=<tipo> N=<numero>
```
*Parámetros:*
- `TIPO`: Identificador de la base de datos (`anio`, `deporte`, `deportista`).
- `N`: Número de carga incremental (`1`, `2`, `3`).

---

## 2. Consulta y Auditoría de Respaldos (msdb)

Para verificar el historial y tamaño de los respaldos sin depender de herramientas gráficas:
```bash
./bin/sql.sh backup/listar_respaldos.sql msdb
```
Muestra: base de datos, tipo (FULL o DIFERENCIAL), fecha de inicio y fin, duración en segundos, tamaño en MB y ruta del archivo físico.

---

## 3. Procedimiento de Restauración ante Contingencias

Antes de restaurar, debe asegurarse el acceso exclusivo cerrando cualquier conexión activa:

### A. Restauración Exclusiva de Respaldo Completo (Paso 0)
Recupera la base de datos a su estado inicial:
```bash
./bin/sql.sh restauracion/restaurar_full.sql master TIPO=<tipo>
```
Aplica el archivo `_0_full.bak` con la cláusula `RECOVERY`, dejando la base disponible de inmediato.

### B. Restauración de Respaldo Completo + Diferencial
Recupera la base aplicando los cambios acumulados hasta el diferencial seleccionado:
```bash
# 1. Eliminar la base de datos dañada o inconsistente
./bin/sql.sh restauracion/eliminar_bd.sql master TIPO=<tipo>

# 2. Aplicar el FULL con NORECOVERY y luego el DIFERENCIAL con RECOVERY
./bin/sql.sh restauracion/restaurar_diferencial.sql master TIPO=<tipo> N=<numero>
```

---

## 4. Validación Posterior a la Restauración

Para certificar que la recuperación fue exitosa y sin pérdida de datos:
```bash
./bin/validar.sh <tipo>
```
*Criterios de aceptación:*
1. **Conteos de filas:** Deben coincidir con los registros cargados hasta la fase correspondiente.
2. **Huellas:** El hash resultante de cada tabla debe ser idéntico al registrado antes del borrado.
3. **Consistencia estructural:** La sentencia final debe reportar `DBCC CHECKDB terminado sin errores`.
