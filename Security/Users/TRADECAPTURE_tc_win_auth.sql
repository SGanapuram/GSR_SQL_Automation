IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TRADECAPTURE\tc_win_auth')
CREATE LOGIN [TRADECAPTURE\tc_win_auth] FROM WINDOWS
GO
CREATE USER [TRADECAPTURE\tc_win_auth] FOR LOGIN [TRADECAPTURE\tc_win_auth]
GO