/* =============================================================================
   por_deporte.sql  —  Carga 2: POR DEPORTE (un evento en distintas ediciones)
   -----------------------------------------------------------------------------
   Evento elegido: 100 metros planos femeninos ("Athletics Women's 100 metres")
   Ejecutar:  bin/cargar.sh deporte <N>
     N = 1  ->  Pekin 2008    (85 filas fuente)
     N = 2  ->  Londres 2012  (79 filas fuente)
     N = 3  ->  Rio 2016      (80 filas fuente)
   Para usar otro evento, cambia @evento por el nombre exacto que aparece en la
   columna "evento" de olimpiadas_staging.dbo.vw_fuente.
   ============================================================================= */
SET NOCOUNT ON;

DECLARE @n      INT          = $(N);
DECLARE @evento VARCHAR(100) = 'Athletics Women''s 100 metres';

IF @n = 1
    EXEC dbo.sp_cargar @tipo = 'deporte', @descripcion = 'Carga 1 por deporte: 100 m femenino Pekin 2008',
                       @anio = 2008, @evento = @evento;
ELSE IF @n = 2
    EXEC dbo.sp_cargar @tipo = 'deporte', @descripcion = 'Carga 2 por deporte: 100 m femenino Londres 2012',
                       @anio = 2012, @evento = @evento;
ELSE IF @n = 3
    EXEC dbo.sp_cargar @tipo = 'deporte', @descripcion = 'Carga 3 por deporte: 100 m femenino Rio 2016',
                       @anio = 2016, @evento = @evento;
ELSE
    RAISERROR('N debe ser 1, 2 o 3.', 16, 1);
GO
