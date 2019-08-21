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
EXEC sp_addrolemember N'next_usr', N'uurt'
GO
GRANT CREATE PROCEDURE TO [next_usr]
