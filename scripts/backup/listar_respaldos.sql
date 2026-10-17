-- Listar catálogo histórico de respaldos generados
SELECT 
    b.database_name AS base_datos,
    CASE b.type 
        WHEN 'D' THEN 'FULL'
        WHEN 'I' THEN 'DIFERENCIAL'
        WHEN 'L' THEN 'LOG'
        ELSE b.type 
    END AS tipo_backup,
    b.backup_start_date AS fecha_inicio,
    b.backup_finish_date AS fecha_fin,
    DATEDIFF(SECOND, b.backup_start_date, b.backup_finish_date) AS duracion_seg,
    CAST(b.backup_size / 1048576.0 AS DECIMAL(10, 2)) AS tamano_mb,
    m.physical_device_name AS ruta_archivo
FROM msdb.dbo.backupset AS b
JOIN msdb.dbo.backupmediafamily AS m ON m.media_set_id = b.media_set_id
WHERE b.database_name LIKE 'olimpiadas_%'
ORDER BY b.backup_start_date;
GO
