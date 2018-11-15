IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ICTS\egraziosi')
CREATE LOGIN [ICTS\egraziosi] FROM WINDOWS
GO
CREATE USER [ICTS\egraziosi] FOR LOGIN [ICTS\egraziosi]
GO
