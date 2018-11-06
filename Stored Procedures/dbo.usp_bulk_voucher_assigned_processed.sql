SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_bulk_voucher_assigned_processed] 
(
   @queue_id    int,
   @status      char(10)
)
as
set nocount on 
set xact_abort on  
declare @rows_affected int

   if ((@queue_id is null) or (@status is null) )
   begin
	    print '=> No values passed to parameters for ''queue_id'' or ''status'' '
	    goto endofscript
   end
   else
   begin
	    begin tran	
	    begin try 
		    insert into dbo.bulk_voucher_processed
		          (queue_id, voucher_num, action_type, creation_date, 
		           start_date, end_date, inst_num, status, misc_col)
		      select queue_id, voucher_num, action_type, creation_date, 
		             start_date, getdate(), inst_num, @status , misc_col
		      from dbo.bulk_voucher_assigned 
		      where queue_id = @queue_id
			  set @rows_affected = @@rowcount
	    end try
	    begin catch
        if @@trancount > 0
           rollback tran
        print '=> Failed to insert queue_id ' + convert(varchar, @queue_id) + ' into bulk_voucher_processed table due to!'
        print '==> ERROR: ' + ERROR_MESSAGE()
        goto endofscript
	    end catch
	
	    begin try 
		    delete dbo.bulk_voucher_assigned 
		    where queue_id = @queue_id
			  set @rows_affected = @@rowcount
	    end try
	    begin catch
        if @@trancount > 0
           rollback tran
        print '=> Failed to delete record queue_id ' + convert(varchar, @queue_id) + ' from bulk_voucher_assigned table due to!'
        print '==> ERROR: ' + ERROR_MESSAGE()
        goto endofscript
	    end catch
	    commit tran
   end

   select @queue_id as queue_id

endofscript:
GO
GRANT EXECUTE ON  [dbo].[usp_bulk_voucher_assigned_processed] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_bulk_voucher_assigned_processed', NULL, NULL
GO
