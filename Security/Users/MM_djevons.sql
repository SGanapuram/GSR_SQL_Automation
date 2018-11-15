IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MM\djevons')
CREATE LOGIN [MM\djevons] FROM WINDOWS
GO
CREATE USER [MM\djevons] FOR LOGIN [MM\djevons]
GO
