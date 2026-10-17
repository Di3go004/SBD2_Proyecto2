-- Respaldo completo inicial (Paso 0)
BACKUP DATABASE [olimpiadas_$(TIPO)]
TO DISK = N'/var/opt/mssql/respaldos/$(TIPO)_0_full.bak'
WITH INIT, CHECKSUM, STATS = 25;

RESTORE VERIFYONLY
FROM DISK = N'/var/opt/mssql/respaldos/$(TIPO)_0_full.bak'
WITH CHECKSUM;
GO
