-- Respaldo diferencial tras carga incremental N
BACKUP DATABASE [olimpiadas_$(TIPO)]
TO DISK = N'/var/opt/mssql/respaldos/$(TIPO)_$(N)_diff.bak'
WITH DIFFERENTIAL, INIT, CHECKSUM, STATS = 25;

RESTORE VERIFYONLY
FROM DISK = N'/var/opt/mssql/respaldos/$(TIPO)_$(N)_diff.bak'
WITH CHECKSUM;
GO
