IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MM\hsr')
CREATE LOGIN [MM\hsr] FROM WINDOWS
GO
CREATE USER [MM\hsr] FOR LOGIN [MM\hsr]
GO
