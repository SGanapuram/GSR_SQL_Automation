CREATE ROLE [next_usr]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'next_usr', N'icts_java'
GO
EXEC sp_addrolemember N'next_usr', N'icts_user'
GO
EXEC sp_addrolemember N'next_usr', N'ictspass'
GO
EXEC sp_addrolemember N'next_usr', N'ictssrvr'
GO
EXEC sp_addrolemember N'next_usr', N'MOH\amph0ra'
GO
EXEC sp_addrolemember N'next_usr', N'MOH\Amphora_Users'
GO
EXEC sp_addrolemember N'next_usr', N'MOH\AmphoraCoral'
GO
EXEC sp_addrolemember N'next_usr', N'MOH\apapazidis'
GO
EXEC sp_addrolemember N'next_usr', N'MOH\SYMPHONY_PROD_USERS'
GO
EXEC sp_addrolemember N'next_usr', N'TRADECAPTURE\tc_win_auth'
GO
EXEC sp_addrolemember N'next_usr', N'uurt'
GO
GRANT CREATE PROCEDURE TO [next_usr]
