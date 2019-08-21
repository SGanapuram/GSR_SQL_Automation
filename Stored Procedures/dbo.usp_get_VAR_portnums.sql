SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_VAR_portnums]   
(  
   @top_port_num          int,  
   @trading_entity_num    int = 0  
)  
as  
set nocount on  
declare @rows_affected     int,  
        @start_time        datetime,  
        @end_time          datetime  
		
   if object_id('tempdb..#jms_reports', 'U') is not null
	  exec('drop table #jms_reports')
  
   select * 
      into #jms_reports 
   from dbo.jms_reports 
   where classification_code NOT like '[A,a]%'  
  
   begin try  
     set @start_time = getdate()  
     INSERT INTO #portnums  
     SELECT port_num, 0, port_type, trading_entity_num  
     FROM dbo.udf_portfolio_list(@top_port_num) a  
     WHERE not exists (select 1  
                       from #portnums p  
                       where a.port_num = p.port_num) and  
           port_type = 'R' and  
           port_locked = 0 and  
           1 = case when @trading_entity_num = 0 then 1  
                    when isnull(trading_entity_num, 0) = @trading_entity_num then 1  
                    else 0  
               end  
     set @rows_affected = @@rowcount  
     set @end_time = getdate()  
   end try  
   begin catch  
     print '=> Failed to copy children port # into the temp table #portnums due to the error:'  
     print '==> ERROR: ' + ERROR_MESSAGE()  
     goto endofsp  
   end catch  
   print '# of children port # saved into the temp table ''#portnums'' = ' + cast(@rows_affected as varchar)  
  
   begin try  
     set @start_time = getdate()  
    
     DELETE p1  
     FROM #portnums p1  
     WHERE exists (select 1  
                   from #jms_reports jms  
                   where p1.port_num = jms.port_num) and  
           p1.port_type = 'R'    
     set @rows_affected = @@rowcount  
     set @end_time = getdate()  
   end try  
   begin catch  
     print '=> Failed to remove inactive REAL port # from temp table due to the error:'  
     print '==> ERROR: ' + ERROR_MESSAGE()  
     goto endofsp  
   end catch  
   print '# of inactive REAL port # were removed from the temp table ''#portnums'' = ' + cast(@rows_affected as varchar)  
     
endofsp:  

if object_id('tempdb..#jms_reports') is not null
	drop table #jms_reports
	
return 1  
GO
GRANT EXECUTE ON  [dbo].[usp_get_VAR_portnums] TO [next_usr]
GO
