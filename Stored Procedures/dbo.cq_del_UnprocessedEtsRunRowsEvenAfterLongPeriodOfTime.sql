SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[cq_del_UnprocessedEtsRunRowsEvenAfterLongPeriodOfTime] 
   @environment     varchar(222) = NULL,
   @to_address	    varchar(555) = NULL,
   @time_in_mins 	int	=	30 
as 
set nocount on 
declare @cr						char(1) 
        ,@lf					char(1) 
        ,@to					varchar(555)  
        ,@from					varchar(255) 
        ,@subject				varchar(255)  
        ,@body					varchar(8000)
        ,@errcode				int
        ,@rows_affected			int
		,@rows_affected2		int
		,@testmode				bit	
        ,@errmsg				varchar(2000)
        ,@oid					int  
		,@et_trans_id			numeric(32,0)
		,@external_trade_oid	int
		,@instance_num			smallint
		,@start_time			datetime
		,@end_time				datetime		
				
   if @to_address is null
   begin
	print 'Please provide value for @to_address .. '
	print 'Usage : exec cq_del_UnprocessedEtsRunRowsEvenAfterLongPeriodOfTime @environment = ''AMPHORA PROD'', @to_address = ''amphora_dba@amphorainc.com'' '
        goto endofsp
   end

   if @environment is null
   begin
	print 'Please provide value for @environment .. '
	print 'Usage : exec cq_del_UnprocessedEtsRunRowsEvenAfterLongPeriodOfTime @environment = ''AMPHORA PROD'', @to_address = ''amphora_dba@amphorainc.com'' '
        goto endofsp
   end

set @testmode = 0
set @cr = char(13)  
set @lf = char(10) + char(13)  
set @from = 'DBAlert@mercuria.com'  

set @errcode = 0
  
-- Create the required temporary tables. 

create table #result
(
	oid					int 		IDENTITY primary key
	,et_trans_id			numeric(32,0)
	,external_trade_oid	int
	,instance_num			smallint
	,start_time			datetime
	,end_time				datetime
 ) 
begin try
  insert into #result
		(
		et_trans_id			
		,external_trade_oid		
		,instance_num			
		,start_time				
		,end_time					
		)
		select
		et_trans_id			
		,external_trade_oid		
		,instance_num			
		,start_time				
		,end_time				
		from ets_run 
		where datediff(mi,start_time,getdate()) > @time_in_mins 
		and end_time is null

		select @rows_affected = @@rowcount
		
end try
begin catch
  set @errmsg = '=> Failed to save records into the #result due to the ERROR: ' + ERROR_MESSAGE()
  set @errcode = ERROR_NUMBER()
  goto endofsp 
end catch

   set @subject = @environment + ' CQ -  ETS Multi-Instance : Unprocessed ets_run rows even after '+cast(@time_in_mins as varchar)+' mins' 
if @rows_affected <> 0  
begin  
	 
set @body = 'select * from ets_run where datediff(mi,start_time,getdate()) > '+cast(@time_in_mins as varchar) +' and end_time is null'+ @lf + @lf 

   set @body = @body + '=> # of records returned by this control query = ' + cast(@rows_affected as varchar) + @lf + @lf 

   select @oid = min(oid) from #result     
   while(@oid is not null)  
   begin  
      select 
			@et_trans_id			= et_trans_id		
			,@external_trade_oid	= external_trade_oid	
			,@instance_num			= instance_num		
			,@start_time			= start_time			
			,@end_time				= end_time	
      from #result  
      where oid = @oid  
		set @body = @body + isnull(cast(@et_trans_id			as varchar), 'NULL') + ', '	
		set @body = @body + isnull(cast(@external_trade_oid		as varchar), 'NULL') + ', '	
		set @body = @body + isnull(cast(@instance_num			as varchar), 'NULL') + ', '	
		set @body = @body + isnull(cast(@start_time				as varchar), 'NULL') + ', '	
		set @body = @body + isnull(cast(@end_time				as varchar), 'NULL') + ', '	+ @lf + @lf 
      select @oid = min(oid)  
      from #result  
      where oid > @oid  
   end   
/*********************** Fix ******************************/   
	if exists (select 1 from #result)
	begin
		begin tran
			begin try
				delete from ets_run where datediff(mi,start_time,getdate()) > @time_in_mins and end_time is null
			
			select @rows_affected2 = @@rowcount
			end try
			begin catch
				if @@trancount > 0
					rollback tran
				print 'Failed to delete records from ets_run'
				print ERROR_MESSAGE()
				goto endofsp
			end catch
		commit tran
		set @body = @body + @lf + @lf + 'FIX : => ' + cast(@rows_affected2 as varchar)+' records deleted by this control query '+ @lf + @lf 
	end 
/*********************** End ******************************/   
exec master.dbo.sp_SQLNotify @from, @to_address, @subject, @body
end
-- The following ELSE statement is used to test to see if notification email would be sent out successfully
else
begin
if @testmode = 1
	exec master.dbo.sp_SQLNotify @from, @to_address, @subject, 'No records found!'
end

endofsp:
if @errcode > 0
begin
	if @errmsg is null
	set @errmsg = 'UNKNOWN error'
	 
	-- Set the subject line for the email. 
	set @subject = @environment + ' - CQ - Error occurred inside the ''cq_del_UnprocessedEtsRunRowsEvenAfterLongPeriodOfTime'' sp' 
	set @body = @errmsg + @lf
	 
	-- Send the email. 
	exec master.dbo.sp_SQLNotify @from, @to_address, @subject, @body 
end
 
-- Drop the temporary tables that were created.
if object_id('tempdb..#result', 'U') is not null
exec('drop table #result')
GO
GRANT EXECUTE ON  [dbo].[cq_del_UnprocessedEtsRunRowsEvenAfterLongPeriodOfTime] TO [next_usr]
GO
