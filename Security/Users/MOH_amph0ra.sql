IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MOH\amph0ra')
CREATE LOGIN [MOH\amph0ra] FROM WINDOWS
GO
CREATE USER [MOH\amph0ra] FOR LOGIN [MOH\amph0ra]
GO
