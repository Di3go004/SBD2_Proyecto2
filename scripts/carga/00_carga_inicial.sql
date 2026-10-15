/* =============================================================================
   00_carga_inicial.sql  —  Carga inicial (igual para los 3 tipos de carga)
   -----------------------------------------------------------------------------
   Inserta el catálogo de países (230 NOC). Después de esta carga va el
   RESPALDO COMPLETO (full backup).

   Ejecutar:  bin/cargar.sh <anio|deporte|deportista> 0
   ============================================================================= */
EXEC dbo.sp_carga_inicial;
GO
