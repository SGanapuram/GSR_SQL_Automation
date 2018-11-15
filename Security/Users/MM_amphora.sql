IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MM\amphora')
CREATE LOGIN [MM\amphora] FROM WINDOWS
GO
CREATE USER [MM\amphora] FOR LOGIN [MM\amphora]
GO
