IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ICTS\mcleary')
CREATE LOGIN [ICTS\mcleary] FROM WINDOWS
GO
CREATE USER [ICTS\mcleary] FOR LOGIN [ICTS\mcleary]
GO
