IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MM\abrown')
CREATE LOGIN [MM\abrown] FROM WINDOWS
GO
CREATE USER [MM\abrown] FOR LOGIN [MM\abrown]
GO
