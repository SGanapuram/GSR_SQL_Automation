SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_delete_trade_item]
( 
   @tradeNum      int = null,
   @orderNum      int = null,
   @itemNum       int = null,
   @tradeTransId  int = null,
   @aTransId	    int = null
)
as
set nocount on
declare @orderTypeCode    varchar(8)
declare @modificationDate datetime
declare @oldModDate       datetime
declare @rowCount         int
declare @temp             int
declare @oldTransId       int

   if (@tradeNum = null) or (@orderNum = null) or (@itemNum = null)
      return -554

   /* find out if the trade has been modified since */
   select @oldTransId = trans_id 
   from dbo.trade 
   where trade_num = @tradeNum

   if (@oldTransId != @tradeTransId)
      return -544

   select @orderTypeCode = order_type_code 
   from dbo.trade_order 
   where trade_num = @tradeNum and 
         order_num = @orderNum

   select @modificationDate = getdate()
   select @temp = trade_num 
   from dbo.trade_item_fill 
   where trade_num = @tradeNum and 
         order_num = @orderNum and 
         item_num = @itemNum
   select @rowCount = @@rowcount
   if (@rowCount > 0) 
   begin
      /* Update the fill with a fill_status = 'D' and then delete the fill
         Doing this, creates an audit entry into the database with the 'D'
         create_risc_file and procedures like it can easily find all the fills
         that have been deleted and send deletes to R&N appropriately.  IF this
         is not done, there is not easy and fast method of finding all deleted fills.*/
	    update dbo.trade_item_fill 
	    set fill_status = 'D', 
	        trans_id = @aTransId
	    where trade_num = @tradeNum and 
	          order_num = @orderNum and 
	          item_num = @itemNum
	          
      delete from dbo.trade_item_fill 
      where trade_num = @tradeNum and 
            order_num = @orderNum and 
            item_num = @itemNum
      if (@@rowcount != @rowCount)
         return -564
   end

   if (@orderTypeCode = 'FUTURE')  
   begin
      delete from dbo.trade_item_fut 
      where trade_num = @tradeNum and 
            order_num = @orderNum and 
            item_num = @itemNum
      if (@@rowcount != 1)
         return -563
   end
   else 
   begin
      delete from dbo.trade_item_exch_opt 
      where trade_num = @tradeNum and 
            order_num = @orderNum and 
            item_num = @itemNum
      if (@@rowcount != 1)
         return -567
   end

   delete from dbo.trade_item 
   where trade_num = @tradeNum and 
         order_num = @orderNum and 
         item_num = @itemNum
   if (@@rowcount != 1)
      return -562
   return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_delete_trade_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_delete_trade_item', NULL, NULL
GO
