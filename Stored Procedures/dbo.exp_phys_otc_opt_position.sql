SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[exp_phys_otc_opt_position]
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

   /* Since ALS will update the position table, so we must include 
      update and delete trade_item_dist statements inside a BEGIN
      TRAN / ROLLBACK TRAN / COMMIT TRAN block to make sure that
      the following records won't appear in transaction_touch table
   
        entity_name    operation   trans_id  sequence   touch_key
        -------------- ----------- --------  ---------- -----------
        TradeItemDist  UPDATE      1         1          1
        TradeItemDist  UPDATE      1         1          2
        TradeItemDist  UPDATE      1         1          3
        TradeItemDist  UPDATE      1         1          4
        Position       UPDATE      2         2          5

        TradeItemDist  DELETE      1         1          6
        TradeItemDist  DELETE      1         1          7
        TradeItemDist  DELETE      1         1          8
        TradeItemDist  DELETE      1         1          9

       Depending on the network/database performance, without using
       BEGIN TRAN / ROLLBACK TRAN / COMMIT TRAN block, it is possible
       that the records with entity_name 'TradeItemDist' and operation
       'UPDATE' were created in transaction_touch table. Before the
       records with entity_name 'TradeItemDist' and operation 'DELETE'
       were created in the transaction_touch table, ALS module saw the
       4 UPDATE records with sequence #1 in transaction_touch table,
       so it processed them, and saw no more transaction_touch records
       with sequence #1. Therefore, ALS module thought that it had processed
       all the transaction_touch records with sequence #1, thus, it increased
       the last_sequence in the server table to 2.
       
       The ALSmodule then processed the transaction_touch record with
       entity_name 'Position' and operation 'UPDATE' because this record
       has sequence #2.

       Becuase the 4 DELETE records (with sequence #1) were added into 
       transaction_touch table after the last_sequence number in the 
       server table was increased, these records won't be processed.
   */

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

   delete dbo.trade_item_dist
   where dist_num in (select distinct child_d.dist_num
		                  from dbo.trade_item_dist parent_d, 
                           dbo.trade_item_dist child_d,
                           dbo.trade_order tor, 
                           dbo.trade_item_otc_opt tioo
		                  where parent_d.pos_num = @pos_num and
			                      parent_d.trade_num = tioo.trade_num and
			                      parent_d.order_num = tioo.order_num and
			                      parent_d.item_num = tioo.item_num and
			                      tioo.strike_excer_date is null and
                            parent_d.trade_num = tor.trade_num and
			                      parent_d.order_num = tor.parent_order_num and
			                      tor.order_type_code in ('PHYSICAL','SWAP','SWAPFLT') and
		                        tor.trade_num = child_d.trade_num and
			                      tor.order_num = child_d.order_num and
           	                child_d.is_equiv_ind = 'Y')
   select @errcode = @@error
   if @errcode > 0
   begin
      rollback tran
      return 104
   end
   commit tran
return 0
GO
GRANT EXECUTE ON  [dbo].[exp_phys_otc_opt_position] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'exp_phys_otc_opt_position', NULL, NULL
GO
