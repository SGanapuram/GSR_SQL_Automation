SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_DBA_fix_dbuser_login_links]
as
set nocount on
declare @username    sysname,
        @sql         varchar(1000),
        @errcode     int,
        @smsg        varchar(max),
        @schema_name nvarchar(128)
        
   select @username = min(name) 
   from dbo.sysusers (nolock)
   where uid <> gid and 
         name not in ('guest', 'INFORMATION_SCHEMA', 'sys', 'dbo') and
         suser_sname(sid) is null and 
         issqlrole = 0

   while @username is not null
   begin
      if exists (select 1
                 from master.dbo.syslogins (nolock)
                 where name = @username)
      begin
         set @sql = 'alter user [' + @username + '] with login = [' + @username + ']'
         begin try
           exec(@sql)
         end try
         begin catch
           set @smsg = ERROR_MESSAGE()
           set @errcode = ERROR_NUMBER()
           RAISERROR('=> Failed to re-establish user ''%s'' in database due to the error:', 0, 1, @username) with nowait
           RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
           break
         end catch 
         RAISERROR('=> The user ''%s'' was re-established in database', 0, 1, @username) with nowait
      end
      else
      begin
         RAISERROR('=> The user ''%s'' does not have login ID. So, drop it from database!', 0, 1, @username) with nowait
         set @schema_name = null
         select @schema_name = SCHEMA_NAME 
         from INFORMATION_SCHEMA.SCHEMATA
         where SCHEMA_OWNER = @username
         
         RAISERROR('=> Dropping the schema ''%s'' if EXISTS ...', 0, 1, @schema_name) with nowait
         if @schema_name is not null and 
            @schema_name not in ('sys', 's2ss', 'dbo', 'INFORMATION_SCHEMA', 'guest') and
            @schema_name not like 'db/_%' ESCAPE '/'
         begin
            RAISERROR('==> Found schema, drop it ...', 0, 1) with nowait
            exec('drop schema ' + @schema_name)
            if SCHEMA_ID(@schema_name) is null
            begin
               RAISERROR('===> The schema ''%s'' was dropped successfully', 0, 1, @schema_name) with nowait
               RAISERROR('=> Dropping the user [%s] does not have login ...', 0, 1, @username) with nowait
               select @sql = 'drop user [' + @username + ']'
               exec(@sql)
               RAISERROR('==> The user [%s] was dropped ...', 0, 1, @username) with nowait
            end
            else
               RAISERROR('===> FAILED to drop the schema ''%s''!', 0, 1, @schema_name) with nowait
         end
         else
         begin
            RAISERROR('=> Dropping the user [%s] does not have login ...', 0, 1, @username) with nowait
            select @sql = 'drop user [' + @username + ']'
            exec(@sql)
            RAISERROR('==> The user [%s] was dropped ...', 0, 1, @username) with nowait
         end
      end

      select @username = min(name) 
      from dbo.sysusers with (nolock)
      where uid <> gid and 
            name not in ('guest', 'INFORMATION_SCHEMA', 'sys', 'dbo') and
            suser_sname(sid) is null and 
            issqlrole = 0 and
            name > @username
   end
GO
