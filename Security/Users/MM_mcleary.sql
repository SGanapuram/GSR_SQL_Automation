IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MM\mcleary')
CREATE LOGIN [MM\mcleary] FROM WINDOWS
GO
CREATE USER [MM\mcleary] FOR LOGIN [MM\mcleary]
GO
