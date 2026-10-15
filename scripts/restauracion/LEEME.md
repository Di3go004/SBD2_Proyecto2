# scripts/restauracion — Responsable: Persona 2

Aquí van los scripts de borrado y restauración:

- `eliminar_bd.sql`: `DROP DATABASE` de la base del tipo (antes, correr `bin/validar.sh` y guardar las huellas).
- `restaurar_full.sql`: restaura solo el respaldo completo, `WITH RECOVERY`.
- `restaurar_diferencial.sql`: restaura el FULL `WITH NORECOVERY` y luego el diferencial N `WITH RECOVERY`.

SQL Server imprime el tiempo de cada restauración ("... processed N pages in X seconds").
Copien ese número a la tabla de tiempos. Después de cada restauración:
`bin/validar.sh <tipo>` + `bin/ver_tablas.sh <tipo>` + capturas.

Los comandos base están en el plan del grupo.
