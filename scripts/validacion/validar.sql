/* =============================================================================
   validar.sql  —  Validación después de cada carga y de cada restauración
   -----------------------------------------------------------------------------
   Ejecutar:  bin/validar.sh <anio|deporte|deportista>
   Muestra, en este orden:
     1. Base de datos y fecha/hora del servidor
     2. SELECT COUNT(*) de cada tabla + "huella" (checksum) del contenido
     3. Bitácora de cargas (qué cargas contiene la base)
     4. Nivel de fragmentación de los índices de cada tabla
     5. DBCC CHECKDB (integridad física de la base)
   Compara los conteos con docs/conteos_esperados.md.
   La huella de cada tabla debe ser IGUAL antes de borrar la base y después de
   restaurar el respaldo equivalente: así se demuestra que no se perdió nada.
   ============================================================================= */
SET NOCOUNT ON;

SELECT DB_NAME() AS base_de_datos, SYSDATETIME() AS fecha_hora_servidor;

/* 2. Conteo + huella por tabla */
SELECT 'pais'           AS tabla, COUNT(*) AS filas, CHECKSUM_AGG(BINARY_CHECKSUM(*)) AS huella FROM dbo.pais
UNION ALL SELECT 'edicion',        COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM dbo.edicion
UNION ALL SELECT 'deporte',        COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM dbo.deporte
UNION ALL SELECT 'evento',         COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM dbo.evento
UNION ALL SELECT 'deportista',     COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM dbo.deportista
UNION ALL SELECT 'participacion',  COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM dbo.participacion
UNION ALL SELECT 'resultado',      COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM dbo.resultado
UNION ALL SELECT 'bitacora_carga', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM dbo.bitacora_carga;

/* 3. Bitácora de cargas */
SELECT carga_id, fecha_hora, tipo, descripcion, filas_fuente, filas_insertadas, duracion_ms
FROM dbo.bitacora_carga
ORDER BY carga_id;

/* 4. Fragmentación de índices
      Nota para el análisis: en tablas con menos de ~1000 páginas el porcentaje
      es poco representativo (pocas páginas = porcentajes altos o cero). */
SELECT OBJECT_NAME(s.object_id)                              AS tabla,
       i.name                                                AS indice,
       i.type_desc                                           AS tipo_indice,
       CAST(s.avg_fragmentation_in_percent AS DECIMAL(5, 2)) AS fragmentacion_pct,
       s.page_count                                          AS paginas
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS s
JOIN sys.indexes AS i
  ON i.object_id = s.object_id
 AND i.index_id  = s.index_id
WHERE OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
  AND i.index_id > 0
ORDER BY tabla, i.index_id;

/* 5. Integridad física. Si hay algún problema, CHECKDB muestra el error. */
DBCC CHECKDB WITH NO_INFOMSGS;
PRINT 'DBCC CHECKDB terminado sin errores.';
GO
