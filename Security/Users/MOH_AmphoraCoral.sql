IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MOH\AmphoraCoral')
CREATE LOGIN [MOH\AmphoraCoral] FROM WINDOWS
GO
CREATE USER [MOH\AmphoraCoral] FOR LOGIN [MOH\AmphoraCoral]
GO
