SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_save_dashboard_error]                              
(
   @report_name         varchar(80),  
   @occurred_at         varchar(80), 
   @problem_desc        varchar(200) = null,                                            
   @dberror_msg         varchar(800) = null,
   @sql_stmt            varchar(max) = null,
   @debugon             bit = 0                            
)                             
as                             
set nocount on      
declare @smsg            varchar(800),
        @days            int,
        @rows_affected   int
        
        
   if exists (select 1
              from dbo.dashboard_configuration
              where config_name = 'ErrorlogPurgeDays')
      select @days = cast(config_value as int)
      from dbo.dashboard_configuration                                            
      where config_name = 'ErrorlogPurgeDays'
   else
   begin
      insert into dbo.dashboard_configuration (config_name, config_value)
         values('ErrorlogPurgeDays', '7')
      select @days = 7
   end

   if @days > 0
   begin
      begin try
        delete dbo.dashboard_errorlog
        where datediff(day, creation_date, getdate()) > @days
        set @rows_affected = @@rowcount
      end try
      begin catch
        if @debugon = 1
        begin
           set @smsg = '=> Failed to purge aging error records from the dashboard_errorlog table due to the error:'
           RAISERROR(@smsg, 0, 1) WITH NOWAIT
        end
        return 1
      end catch
      -- if @debugon = 1
      -- begin
      --    set @smsg = '=> ' + cast(@rows_affected as varchar) + ' aging error records were removed from the dashboard_errorlog table!'
      --   RAISERROR(@smsg, 0, 1) WITH NOWAIT
      -- end
   end
   
   begin try
     insert into dbo.dashboard_errorlog
       (creation_date, logged_by, report_name, occurred_at, problem_desc, dberror_msg, sql_stmt, session_id)
      values(getdate(), suser_sname(), @report_name, @occurred_at, @problem_desc, @dberror_msg, @sql_stmt, @@spid) 
   end try
   begin catch
     set @smsg = '=> Failed to save an error record into the dashboard_errorlog table due to the error:'
     RAISERROR(@smsg, 0, 1) WITH NOWAIT
     return 1
   end catch
   
   return 0
GO
GRANT EXECUTE ON  [dbo].[usp_save_dashboard_error] TO [next_usr]
GO
