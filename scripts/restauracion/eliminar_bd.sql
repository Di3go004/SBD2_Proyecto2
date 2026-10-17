-- Forzar cierre de conexiones activas y eliminar BD
IF DB_ID(N'olimpiadas_$(TIPO)') IS NOT NULL
BEGIN
    ALTER DATABASE [olimpiadas_$(TIPO)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [olimpiadas_$(TIPO)];
    PRINT 'Base de datos olimpiadas_$(TIPO) eliminada correctamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos olimpiadas_$(TIPO) no existia.';
END
GO
