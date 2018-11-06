SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_delete_trade]
(
   @tradeNum		    int = null,
   @orderNum		    int = null,
   @modifierInit	  char(3) = null,
   @tradeTransId	  int = null,
   @newTradeModDate	varchar(30) = null,
   @newTransId		  int = null
)
as
set nocount on
declare @orderTypeCode varchar(8)
declare @modificationDate datetime
declare @rowCount int
declare @temp int
declare @oldTransId int

   /* find out if the trade has been modified since */
   select @oldTransId = trans_id 
   from dbo.trade 
   where trade_num = @tradeNum

   if (@oldTransId != @tradeTransId)
      return -544

   select @modificationDate = getdate()

   /* update trade with the new status */
   update dbo.trade 
   set trade_status_code = 'DELETE',
       trade_mod_date = @newTradeModDate,
       trade_mod_init = @modifierInit,
       trans_id = @newTransId
   where trade_num = @tradeNum and
         trans_id = @tradeTransId
   if (@@rowcount != 1)
      return -557

   select @orderTypeCode = order_type_code 
   from dbo.trade_order 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   if (@@rowCount != 1)
      return -558

   select @temp = trade_num 
   from dbo.trade_item_fill 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   select @rowCount = @@rowcount
   if (@rowCount > 0) 
   begin
      /* Update the fill with a fill_status = 'D' and then delete the fill
         Doing this, creates an audit entry into the database with the 'D'
         create_risc_file and procedures like it can easily find all the fills
         that have been deleted and send deletes to R&N appropriately.  IF this
         is not done, there is not an easy and fast method to find all deleted fills.
      */
      update dbo.trade_item_fill
      set fill_status = 'D',
          trans_id = @newTransId
      where trade_num = @tradeNum
	
      delete from dbo.trade_item_fill 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      if (@@rowcount != @rowCount)
         return -564
   end

   if (@orderTypeCode = 'FUTURE') 
   begin
      select @temp = trade_num 
      from dbo.trade_item_fut 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      select @rowCount = @@rowcount
      if (@rowCount = 0)
         return -556

      delete from dbo.trade_item_fut 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      if (@@rowcount != @rowCount)
         return -563
   end
   else 
   begin
      select @temp = trade_num 
      from dbo.trade_item_exch_opt 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      select @rowCount = @@rowcount
      if (@rowCount = 0)
         return -566

      delete from dbo.trade_item_exch_opt 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      if (@@rowcount != @rowCount)
         return -567
   end

   /* don't delete the pei_comment.  this causes Delphi connection 
      to sybase timeout.  Do not change this ever. 
   select @temp = cmnt_num 
   from dbo.trade_item 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   select @rowCount = @@rowcount
   if (@rowCount = 0)
      return -555
   */

   delete from dbo.trade_item 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   if (@@rowcount != @rowCount)
      return -562

   /* don't delete the pei_comment.  this causes Delphi connection 
      to sybase timeout.  Do not change this ever. 
   if (@temp is not null) 
   begin
      delete from dbo.pei_comment 
      where cmnt_num = @temp
      if (@@rowcount != 1)
         return -587
   end
   */

   delete from dbo.trade_order_on_exch 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   if (@@rowcount != 1)
      return -561

   delete from dbo.trade_order 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   if (@@rowcount != 1)
      return -559
   return @tradeNum
GO
GRANT EXECUTE ON  [dbo].[quickfill_delete_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_delete_trade', NULL, NULL
GO
