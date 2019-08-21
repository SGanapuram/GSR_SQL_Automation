SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[exp_cash_otc_opt_position]
(
   @pos_num			        int,
   @strike_excer_date		datetime,
   @trans_id			      int
)
as
set nocount on
set xact_abort on            
declare @rows_affected   int,
        @errcode         int

   /* close out all open distributions */
   begin tran
   update dbo.trade_item_dist
   set alloc_qty = abs(dist_qty),
       discount_qty = 0.0,
       trans_id = @trans_id
   from dbo.trade_item_dist d1, 
        dbo.trade_item_otc_opt otcopt
   where exists (select 1
	               from dbo.trade_item_dist d2
	               where d1.trade_num = d2.trade_num and
                       d1.order_num = d2.order_num and
                       d1.item_num = d2.item_num and      
	                     d2.pos_num = @pos_num) and
                       d1.trade_num = otcopt.trade_num and
                       d1.order_num = otcopt.order_num and
                       d1.item_num = otcopt.item_num and
                       otcopt.strike_excer_date is null and
                       d1.is_equiv_ind = 'N'
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0 or @rows_affected = 0
   begin
      rollback tran
      return 101
   end

   /* underlying distributions should be deleted too */
   delete dbo.trade_item_dist
   where dist_num in (select d1.dist_num
		                  from dbo.trade_item_dist d1, 
                           dbo.trade_item_dist d2,
			                     dbo.trade_item_otc_opt otcopt
		                  where d2.pos_num = @pos_num and 
                            d1.dist_type = 'D' and
                            d1.is_equiv_ind = 'Y' and
                            d2.trade_num = d1.trade_num and
                            d2.order_num = d1.order_num and
                            d2.item_num = d1.item_num and
                            d1.trade_num = otcopt.trade_num and
                            d1.order_num = otcopt.order_num and
                            d1.item_num = otcopt.item_num and
                            otcopt.strike_excer_date is null)
   select @errcode = @@error
   if @errcode > 0
   begin
      rollback tran
      return 104
   end
   commit tran
return 0
GO
GRANT EXECUTE ON  [dbo].[exp_cash_otc_opt_position] TO [next_usr]
GO
