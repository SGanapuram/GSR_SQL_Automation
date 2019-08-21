SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[exp_exch_position]
(
   @pos_num			        int,
   @strike_excer_date		datetime,
   @trans_id			      int
)
as
set nocount on
set xact_abort on            

   begin tran
   begin try
     update d
     set alloc_qty = abs(dist_qty),
         discount_qty = 0.0,
         trans_id = @trans_id
     from dbo.trade_item_dist d
     where d.pos_num = @pos_num 
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     return 101
   end catch

   begin try
     delete dbo.trade_item_dist
     where dist_num in (select d1.dist_num
		                    from dbo.trade_item_dist d1, 
                             dbo.trade_item_dist d2
		                    where d2.pos_num = @pos_num and 
                              d1.dist_type = 'D' and 
                              d1.is_equiv_ind = 'Y' and 
                              d2.trade_num = d1.trade_num and 
                              d2.order_num = d1.order_num and 
                              d2.item_num = d1.item_num)
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     return 104
   end catch
   commit tran
return 0
GO
GRANT EXECUTE ON  [dbo].[exp_exch_position] TO [next_usr]
GO
