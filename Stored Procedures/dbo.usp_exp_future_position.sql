SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_exp_future_position]
(
   @pos_num            int,
   @trans_id           bigint
)
as
set nocount on
set xact_abort on
declare @rows_affected   int,
        @errcode         int,
        @smsg            varchar(max),
        @my_pos_num      int,
        @my_trans_id     bigint

   select @my_pos_num = @pos_num,
          @my_trans_id  = @trans_id

   if @my_pos_num is null or @my_trans_id is null
   begin
      print 'You must provide values for the arguments @pos_num and @trans_id!'
      goto reportusage
   end
   
   if not exists (select 1
                  from dbo.icts_transaction with (nolock)
                  where trans_id = @my_trans_id)
   begin
      print 'You must provide a valid trans_id for the argument @trans_id!'
      goto reportusage
   end

   if not exists (select 1
                  from dbo.position
                  where pos_num = @my_pos_num)
   begin
      print 'You must provide a valid pos_num for the argument @pos_num!'
      goto reportusage
   end  
    
   begin tran
   begin try
     update d
     set alloc_qty = abs(d.dist_qty),
         discount_qty = 0.0,
         trans_id = @my_trans_id
     from dbo.trade_item_dist d
     where d.pos_num = @my_pos_num 
     set @rows_affected = @@rowcount
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     set @errcode = ERROR_NUMBER()
     set @smsg = ERROR_MESSAGE()
     RAISERROR('=> Failed to update the trade_item_dist table due to the error:', 0, 1) with nowait
     RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
     return 1
   end catch
   commit tran    
   return 0

reportusage:
print 'usage: exec dbo.usp_exp_future_position @pos_num = ?, @trans_id = ?'
return 2
GO
GRANT EXECUTE ON  [dbo].[usp_exp_future_position] TO [next_usr]
GO
