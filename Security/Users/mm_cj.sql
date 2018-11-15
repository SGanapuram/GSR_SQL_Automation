IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'mm\cj')
CREATE LOGIN [mm\cj] FROM WINDOWS
GO
CREATE USER [mm\cj] FOR LOGIN [mm\cj]
GO
