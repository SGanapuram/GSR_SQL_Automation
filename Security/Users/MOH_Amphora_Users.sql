IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MOH\Amphora_Users')
CREATE LOGIN [MOH\Amphora_Users] FROM WINDOWS
GO
CREATE USER [MOH\Amphora_Users] FOR LOGIN [MOH\Amphora_Users]
GO
