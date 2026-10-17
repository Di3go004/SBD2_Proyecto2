# Bitácora de Ejecución de Respaldos y Restauraciones

Este directorio contiene los registros oficiales generados durante la ejecución de los tres ciclos en SQL Server 2022 (Linux Container).

## Nomenclatura de Archivos
- `AAAAMMDD_HHMMSS_<operacion>_<base>.log`

## Registro de Operaciones Validadas
1. **00_version_master.log**: Verificación de instancia SQL Server 2022 Developer Edition.
2. **01_staging_master.log**: Ingesta masiva desde CSVs hacia la base de staging (271,116 atletas y 230 países).
3. **preparar_bd / crear_bd**: Creación de esquema y tablas normalizadas para cada tipo de carga.
4. **eliminar_bd**: Evidencia de ejecución de `DROP DATABASE` con rollback inmediato de conexiones previas a la restauración.
5. **restaurar_full / restaurar_diferencial**: Registros de restauración con conteo de páginas procesadas, velocidad de transferencia (MB/s) y tiempo en segundos.
6. **validar_olimpiadas_<tipo>**: Reportes de conteo por tabla, huellas criptográficas, tiempos de inserción y resultado de `DBCC CHECKDB` sin errores.
