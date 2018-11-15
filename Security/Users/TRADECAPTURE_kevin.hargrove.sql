IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TRADECAPTURE\kevin.hargrove')
CREATE LOGIN [TRADECAPTURE\kevin.hargrove] FROM WINDOWS
GO
CREATE USER [TRADECAPTURE\kevin.hargrove] FOR LOGIN [TRADECAPTURE\kevin.hargrove]
GO
