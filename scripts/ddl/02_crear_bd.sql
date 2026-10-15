/* =============================================================================
   02_crear_bd.sql  —  Crea una base de datos NUEVA y vacía para un tipo de carga
   -----------------------------------------------------------------------------
   Variable sqlcmd: $(BD)  ->  olimpiadas_anio | olimpiadas_deporte | olimpiadas_deportista
   Lo ejecuta bin/preparar_bd.sh (no hace falta correrlo a mano).
   Si la base ya existe, se elimina primero ("instancia nueva" que pide el enunciado).
   ============================================================================= */
SET NOCOUNT ON;

IF DB_ID(N'$(BD)') IS NOT NULL
BEGIN
    PRINT 'La base $(BD) ya existia: se elimina para empezar desde cero.';
    ALTER DATABASE [$(BD)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(BD)];
END
GO

CREATE DATABASE [$(BD)];
GO

/* Modelo de recuperación FULL: permite respaldos completos, diferenciales
   y, si se quiere, respaldos del log de transacciones. */
ALTER DATABASE [$(BD)] SET RECOVERY FULL;
GO

PRINT 'Base $(BD) creada.';
GO
