SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_archive_ets_run]
(
   @ets_run_daysold        		int = 1,
   @ets_run_archive_daysold     int = 30,
   @debug_on					int = 0
)
as
set nocount on
set xact_abort on

declare @rows_affected           int,
        @archived_date           datetime,
		@number_of_records		 int

select @archived_date = convert(datetime, convert(varchar, getdate(), 101))

-- Deleting records from ets_run_archive

if @debug_on = 1
begin
	select @number_of_records = 0
	select @number_of_records = (select count(*) from dbo.ets_run_archive where archived_date < (getdate()-@ets_run_archive_daysold))
	print '=> ' + convert(varchar(10),@number_of_records) + ' Records found to be deleted from ets_run_archive table'
	
	select @number_of_records = 0
	select @number_of_records = (select count(*) from dbo.ets_run where end_time is not null and end_time < (getdate()-@ets_run_daysold))
	print '=> ' + convert(varchar(10),@number_of_records) + ' Records found to be deleted from ets_run table'
	
	goto endofscript
end	

select @rows_affected = 0
	
begin tran
begin try
	delete dbo.ets_run_archive
	where archived_date < (getdate()-@ets_run_archive_daysold)
	select @rows_affected = @@rowcount
end try		
begin catch
	if @@trancount > 0
		rollback tran
	print '=> Failed to delete records from ets_run_archive due to below error'	
	print ERROR_MESSAGE()
	goto endofscript
end catch
print '=> ' + convert(varchar(10),@rows_affected) + ' Records deleted from ets_run_archive table'	
commit tran

-- Before deleting records from ets_run copying the records into ets_run_archive

select @rows_affected = 0
		
begin tran
begin try
		insert into dbo.ets_run_archive
		select 	et_trans_id,
				external_trade_oid,
				instance_num,
				start_time,
				end_time,
				@archived_date
		from ets_run
		where end_time is not null and end_time < (getdate()-@ets_run_daysold)
		select @rows_affected = @@rowcount
end try		
begin catch
	if @@trancount > 0
		rollback tran
	print '=> Failed to insert records into ets_run_archive due to below error'	
	print ERROR_MESSAGE()
	goto endofscript
end catch
print '=> ' + convert(varchar(10),@rows_affected) + ' Records inserted into ets_run_archive table'
commit tran

-- Deleting records from ets_run

select @rows_affected = 0
	
begin tran
begin try
		delete dbo.ets_run
		where end_time is not null and end_time < (getdate()-@ets_run_daysold)
		select @rows_affected = @@rowcount
end try		
begin catch
	if @@trancount > 0
		rollback tran
	print '=> Failed to delete records from ets_run due to below error'	
	print ERROR_MESSAGE()
	goto endofscript
end catch
print '=> ' + convert(varchar(10),@rows_affected) + ' Records deleted from ets_run table'	
commit tran

endofscript:
GO
GRANT EXECUTE ON  [dbo].[usp_archive_ets_run] TO [next_usr]
GO
