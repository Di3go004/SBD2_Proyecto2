/* =============================================================================
   por_anio.sql  —  Carga 1: POR AÑO (una edición completa de los Juegos de Verano)
   -----------------------------------------------------------------------------
   Ejecutar:  bin/cargar.sh anio <N>
     N = 1  ->  Pekin 2008    (13,602 filas fuente)
     N = 2  ->  Londres 2012  (12,920 filas fuente)
     N = 3  ->  Rio 2016      (13,688 filas fuente)
   Después de CADA carga: validar, capturas y respaldo diferencial.
   ============================================================================= */
SET NOCOUNT ON;

DECLARE @n INT = $(N);

IF @n = 1
    EXEC dbo.sp_cargar @tipo = 'anio', @descripcion = 'Carga 1 por anio: Pekin 2008', @anio = 2008;
ELSE IF @n = 2
    EXEC dbo.sp_cargar @tipo = 'anio', @descripcion = 'Carga 2 por anio: Londres 2012', @anio = 2012;
ELSE IF @n = 3
    EXEC dbo.sp_cargar @tipo = 'anio', @descripcion = 'Carga 3 por anio: Rio 2016', @anio = 2016;
ELSE
    RAISERROR('N debe ser 1, 2 o 3.', 16, 1);
GO
