IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MM\bsaraswat')
CREATE LOGIN [MM\bsaraswat] FROM WINDOWS
GO
CREATE USER [MM\bsaraswat] FOR LOGIN [MM\bsaraswat]
GO
