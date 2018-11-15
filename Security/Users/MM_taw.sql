IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MM\taw')
CREATE LOGIN [MM\taw] FROM WINDOWS
GO
CREATE USER [MM\taw] FOR LOGIN [MM\taw]
GO
