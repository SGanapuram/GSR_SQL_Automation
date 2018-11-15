IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ICTS\icts_win_auth')
CREATE LOGIN [ICTS\icts_win_auth] FROM WINDOWS
GO
CREATE USER [ICTS\icts_win_auth] FOR LOGIN [ICTS\icts_win_auth]
GO
