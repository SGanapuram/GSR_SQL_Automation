IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MM\lj')
CREATE LOGIN [MM\lj] FROM WINDOWS
GO
CREATE USER [MM\lj] FOR LOGIN [MM\lj]
GO
