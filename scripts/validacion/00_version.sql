/* Prueba de conexión: bin/sql.sh validacion/00_version.sql */
SET NOCOUNT ON;
SELECT @@VERSION AS version_sql_server, SYSDATETIME() AS fecha_hora_servidor;
GO
