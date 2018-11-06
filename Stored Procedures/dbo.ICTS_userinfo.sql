SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[ICTS_userinfo]
(
   @by_user_logon_id       varchar(20) = null
)
as
begin
set nocount on
declare @num_rows    int,
        @errmsg      varchar(255)

   if (select count(*) from dbo.icts_user) = 0
   begin
      print 'The icts_user table is empty!' 
      return
   end

   create table #userinfo_temp (       
      user_init            char(3)       NULL,
      user_last_name       varchar(20)   NULL,
      user_first_name      varchar(20)   NULL,
      desk_code            char(8)       NULL,
      loc_code             char(8)       NULL,
      user_logon_id        varchar(20)   NULL,
      user_job_title       varchar(40)   NULL,
      user_status          char(1)       NULL,
      defaultdb            varchar(30)   NULL,
      dept_code            char(8)       NULL,
      dept_name            varchar(30)   NULL,
      desk_name            varchar(30)   NULL,
      loc_name             varchar(40)   NULL,
      trading_entity_num   int           NULL,
      acct_full_name       varchar(100)  NULL,
      loc_num              smallint      NULL,
      suid                 varbinary(85) NULL,
      gid                  int           NULL,
      db_username          varchar(30)   NULL,
      user_groupname       varchar(30)   NULL
    )

   if (@by_user_logon_id is null)  
   begin
      insert into #userinfo_temp (
             user_init,
             user_last_name,
             user_first_name,
             desk_code,
             loc_code,
             user_logon_id,
             user_job_title,
             user_status)
      select user_init,
             user_last_name,
             user_first_name,
             desk_code,
             loc_code,
             user_logon_id,
             user_job_title,
             user_status
      from dbo.icts_user
   end
   else
   begin
      insert into #userinfo_temp (
             user_init,
             user_last_name,
             user_first_name,
             desk_code,
             loc_code,
             user_logon_id,
             user_job_title,
             user_status)
      select user_init,
             user_last_name,
             user_first_name,
             desk_code,
             loc_code,
             user_logon_id,
             user_job_title,
             user_status
      from dbo.icts_user
      where user_logon_id = @by_user_logon_id
   end

   select @num_rows = @@rowcount
   if @num_rows = 0
   begin
      if (@by_user_logon_id is null) 
         print 'Failed to get icts_user records!' 
      else
      begin
         select @errmsg = 'Could not locate a icts_user record for the user logon - ' +  @by_user_logon_id + '.'
         print @errmsg
      end
      return
   end

   update #userinfo_temp
   set suid = login.sid,
       defaultdb = login.dbname
   from  master..syslogins login
   where login.name = #userinfo_temp.user_logon_id

   update #userinfo_temp
   set db_username = sysusers.name,
       gid = sysusers.gid
   from sysusers 
   where sysusers.sid = #userinfo_temp.suid

   update #userinfo_temp
   set user_groupname = name 
   from sysusers 
   where sysusers.uid = #userinfo_temp.gid

   update #userinfo_temp
   set dept_code = desk.dept_code,
       desk_name = desk.desk_name
   from desk
   where desk.desk_code = #userinfo_temp.desk_code

   update #userinfo_temp
   set dept_name = department.dept_name,
       trading_entity_num = department.trading_entity_num
   from department 
   where department.dept_code = #userinfo_temp.dept_code
   
   update #userinfo_temp
   set acct_full_name = account.acct_full_name 
   from account 
   where account.acct_num = #userinfo_temp.trading_entity_num

   update #userinfo_temp
   set loc_num = location.loc_num,
       loc_name = location.loc_name
   from location 
   where location.loc_code = #userinfo_temp.loc_code


   print '******************************************************'
   print ' ICTS USER GENERAL INFORMATION'
   print '======================================================'
   select user_init,
          user_last_name + ', ' + user_first_name "user name",
          user_status
   from #userinfo_temp
   order by user_init 

   print ' '
   print '======================================================'
   print ' USER JOB TITLE INFORMATION'
   print '======================================================'
   select user_init,
          user_job_title
   from #userinfo_temp
   order by user_init 

   print ' '
   print '======================================================'
   print ' USER DESK/LOCATION INFORMATION'
   print '======================================================'
   select user_init,
          desk_code,
          loc_code
   from #userinfo_temp
   order by user_init 

   print ' '
   print '======================================================'
   print ' USER LOGON INFORMATION'
   print '======================================================'
   select user_init,
          user_logon_id,
          defaultdb,
          suid
   from #userinfo_temp
   order by user_init 

   print ' '
   print '======================================================'
   print ' ICTS DATABASE USER INFORMATION'
   print '======================================================'
   select user_init,
          db_username,
          user_groupname
   from #userinfo_temp
   order by user_init 

   if (select count(*) from #userinfo_temp where suid is NULL) > 0
   begin
      print ' '
      print '======================================================'
      print ' USER(s) DO NOT HAVE SYBASE LOGIN ACCOUNT(s)'
      print '======================================================'
      select user_init, user_logon_id
      from #userinfo_temp
      where suid is NULL
      order by user_init
   end

   if (select count(*) from #userinfo_temp where db_username is NULL) > 0
   begin
      print ' '
      print '======================================================'
      print ' USER(s) ARE NOT VALID DATABASE USER(s)'
      print '======================================================'
      select user_init, user_logon_id
      from #userinfo_temp
      where db_username is NULL
      order by user_init
   end

   if (select count(*) from #userinfo_temp where desk_name is NULL) > 0
   begin
      print ' '
      print '======================================================'
      print ' USER(s) HAVING INVALID DESK_CODE(s)'
      print '======================================================'
      select user_init, desk_code
      from #userinfo_temp
      where desk_name is NULL
      order by user_init
   end

   if (select count(*) from #userinfo_temp 
       where desk_name <> NULL and dept_code is NOT NULL and dept_name is NULL) > 0
   begin
      print ' '
      print '======================================================'
      print ' DESK(s) HAVING INVALID DEPARTMENT CODE(s)'
      print '======================================================'
      select user_init, desk_code, dept_code
      from #userinfo_temp
      where desk_name <> NULL and dept_code is NOT NULL and dept_name is NULL
      order by user_init
   end

   if (select count(*) from #userinfo_temp where loc_name is NULL) > 0
   begin
      print ' '
      print '======================================================'
      print ' USER(s) HAVING INVALID LOCATION CODE(s)'
      print '======================================================'
      select user_init, loc_code
      from #userinfo_temp
      where loc_name is NULL
      order by user_init
   end

   if (select count(*) from #userinfo_temp 
       where loc_name <> NULL and loc_num is NULL OR loc_num <> 0) > 0
   begin
      print ' '
      print '======================================================'
      print ' USER(s) HAVING LOCATION CODE(s) WITH NON-ZERO LOC_NUM'
      print '======================================================'
      select user_init, loc_code, loc_num
      from #userinfo_temp
      where loc_name <> NULL and loc_num is NULL OR loc_num <> 0
      order by user_init
   end


   drop table #userinfo_temp
end
return
GO
GRANT EXECUTE ON  [dbo].[ICTS_userinfo] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'ICTS_userinfo', NULL, NULL
GO
