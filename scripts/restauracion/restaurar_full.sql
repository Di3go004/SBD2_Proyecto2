-- Restauración de FULL dejando la BD disponible (RECOVERY)
RESTORE DATABASE [olimpiadas_$(TIPO)]
FROM DISK = N'/var/opt/mssql/respaldos/$(TIPO)_0_full.bak'
WITH REPLACE, RECOVERY, STATS = 25;
GO
