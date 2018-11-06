CREATE ROLE [admin_group]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'admin_group', N'icts_admin'
GO
EXEC sp_addrolemember N'admin_group', N'icts_java'
GO
EXEC sp_addrolemember N'admin_group', N'ictssrvr'
GO
EXEC sp_addrolemember N'admin_group', N'MOH\amph0ra'
GO
EXEC sp_addrolemember N'admin_group', N'MOH\Amphora_Users'
GO
EXEC sp_addrolemember N'admin_group', N'MOH\AmphoraCoral'
GO
EXEC sp_addrolemember N'admin_group', N'MOH\apapazidis'
GO
EXEC sp_addrolemember N'admin_group', N'MOH\SYMPHONY_PROD_USERS'
GO
EXEC sp_addrolemember N'admin_group', N'TRADECAPTURE\tc_win_auth'
GO
