# scripts/backup — Responsable: Persona 2

Aquí van los scripts de respaldo, ejecutados por consola con `bin/sql.sh`:

- `backup_full.sql`: respaldo completo después de la carga inicial (paso 0).
- `backup_diferencial.sql`: respaldo diferencial después de cada carga 1, 2 y 3.
- `listar_respaldos.sql`: consulta a `msdb.dbo.backupset` / `backupmediafamily` con fecha, tipo, tamaño y archivo de cada respaldo.

Convención de nombres (los archivos quedan en `./respaldos`):

```
<tipo>_0_full.bak      ej. anio_0_full.bak
<tipo>_<n>_diff.bak    ej. anio_1_diff.bak, anio_2_diff.bak, anio_3_diff.bak
```

Usen variables sqlcmd para no repetir un script por tipo, igual que `carga/por_anio.sql`.
Ejemplo: `bin/sql.sh backup/backup_diferencial.sql master TIPO=anio N=1`

Los comandos base están en el plan del grupo.
