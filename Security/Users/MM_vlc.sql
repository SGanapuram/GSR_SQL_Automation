IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'MM\vlc')
CREATE LOGIN [MM\vlc] FROM WINDOWS
GO
CREATE USER [MM\vlc] FOR LOGIN [MM\vlc]
GO
