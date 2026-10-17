-- 1. Restaurar FULL en espera de más cambios (NORECOVERY)
RESTORE DATABASE [olimpiadas_$(TIPO)]
FROM DISK = N'/var/opt/mssql/respaldos/$(TIPO)_0_full.bak'
WITH REPLACE, NORECOVERY, STATS = 25;

-- 2. Aplicar Diferencial N y poner la BD en línea (RECOVERY)
RESTORE DATABASE [olimpiadas_$(TIPO)]
FROM DISK = N'/var/opt/mssql/respaldos/$(TIPO)_$(N)_diff.bak'
WITH RECOVERY, STATS = 25;
GO
