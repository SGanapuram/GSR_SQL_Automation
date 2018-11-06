IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MOH\apapazidis')
CREATE LOGIN [MOH\apapazidis] FROM WINDOWS
GO
CREATE USER [MOH\apapazidis] FOR LOGIN [MOH\apapazidis]
GO
