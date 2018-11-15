IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ICTS\BSaraswat')
CREATE LOGIN [ICTS\BSaraswat] FROM WINDOWS
GO
CREATE USER [ICTS\BSaraswat] FOR LOGIN [ICTS\BSaraswat]
GO
