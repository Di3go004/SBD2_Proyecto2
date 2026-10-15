/* =============================================================================
   por_deportista.sql  —  Carga 3: POR DEPORTISTA (un atleta en distintas ediciones)
   -----------------------------------------------------------------------------
   Deportista elegido: Usain Bolt (ID 13029 en el dataset, "Usain St. Leo Bolt")
   Ejecutar:  bin/cargar.sh deportista <N>
     N = 1  ->  Atenas 2004   (1 fila fuente: 200 m)
     N = 2  ->  Pekin 2008    (3 filas fuente: 100 m, 200 m, 4x100)
     N = 3  ->  Londres 2012  (3 filas fuente: 100 m, 200 m, 4x100)
   Para buscar el ID de otro deportista:
     SELECT DISTINCT atleta_id, nombre FROM olimpiadas_staging.dbo.vw_fuente
     WHERE nombre LIKE '%Apellido%';
   ============================================================================= */
SET NOCOUNT ON;

DECLARE @n          INT = $(N);
DECLARE @deportista INT = 13029;   -- Usain Bolt

IF @n = 1
    EXEC dbo.sp_cargar @tipo = 'deportista', @descripcion = 'Carga 1 por deportista: Usain Bolt Atenas 2004',
                       @anio = 2004, @deportista_id = @deportista;
ELSE IF @n = 2
    EXEC dbo.sp_cargar @tipo = 'deportista', @descripcion = 'Carga 2 por deportista: Usain Bolt Pekin 2008',
                       @anio = 2008, @deportista_id = @deportista;
ELSE IF @n = 3
    EXEC dbo.sp_cargar @tipo = 'deportista', @descripcion = 'Carga 3 por deportista: Usain Bolt Londres 2012',
                       @anio = 2012, @deportista_id = @deportista;
ELSE
    RAISERROR('N debe ser 1, 2 o 3.', 16, 1);
GO
