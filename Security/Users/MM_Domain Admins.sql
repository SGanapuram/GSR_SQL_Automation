IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MM\Domain Admins')
CREATE LOGIN [MM\Domain Admins] FROM WINDOWS
GO
CREATE USER [MM\Domain Admins] FOR LOGIN [MM\Domain Admins]
GO
