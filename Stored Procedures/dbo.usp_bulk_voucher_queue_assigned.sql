SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_bulk_voucher_queue_assigned] 
(
   @instanceNum int 
)
as
set nocount on 
set xact_abort on  
declare @oid            int,
        @voucherNum     int, 
        @action         char(15), 
        @dt             datetime,
        @misc           varchar(250), 
        @rows_affected	int

SELECT TOP 1 @oid=oid, @voucherNum=voucher_num, @action=action_type, @dt=creation_date, @misc=misc_col 
FROM dbo.bulk_voucher_queue
ORDER BY oid 
 
if @oid is not null
begin

	begin tran
	
	begin try 
		insert into 
		dbo.bulk_voucher_assigned(queue_id,voucher_num,action_type,creation_date,start_date,inst_num,status,misc_col)
		values (@oid, @voucherNum, @action, @dt, getdate(), @instanceNum, 'Processing', @misc) 
			select @rows_affected = @@rowcount
	end try
	begin catch
        if @@trancount > 0
            rollback tran
        print '=> Failed to insert queue_id' + convert(varchar, @oid) + 'into bulk_voucher_assigned table due to!'
        print '==> ERROR: ' + ERROR_MESSAGE()
            goto endofscript
	end catch
	
	begin try 
		delete dbo.bulk_voucher_queue WHERE oid = @oid 
			select @rows_affected = @@rowcount
	end try
	begin catch
        if @@trancount > 0
            rollback tran
        print '=> Failed to delete record oid' + convert(varchar, @oid) +'from bulk_voucher_queue table due to!'
        print '==> ERROR: ' + ERROR_MESSAGE()
            goto endofscript
	end catch
	commit tran

end

	select convert(varchar, @oid) + '#' + convert(varchar, @voucherNum) + '#' + convert(varchar,rtrim(@action)) as result  


endofscript:
GO
GRANT EXECUTE ON  [dbo].[usp_bulk_voucher_queue_assigned] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_bulk_voucher_queue_assigned', NULL, NULL
GO
