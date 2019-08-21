CREATE ROLE [admin_group]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'admin_group', N'icts_admin'
GO
EXEC sp_addrolemember N'admin_group', N'icts_java'
GO
EXEC sp_addrolemember N'admin_group', N'ictssrvr'
GO
