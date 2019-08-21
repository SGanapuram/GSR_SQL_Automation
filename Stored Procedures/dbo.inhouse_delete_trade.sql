SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[inhouse_delete_trade]
(
   @tradeNum			    int = null,
   @orderNum			    int = null,
   @modifierInit		  char(3) = null,
   @transId			      int = null,
   @newTradeModDate		varchar(30) = null,
   @newTransId			  int = null
)
as
set nocount on
declare @orderTypeCode varchar(8)
declare @modificationDate datetime
declare @rowCount int
declare @temp int
declare @oldModDate datetime
declare @oldTransId int

   /* find out if the trade has been modified since */
   select @oldTransId = trans_id 
   from dbo.trade 
   where trade_num = @tradeNum

   if (@oldTransId != @transId)
      return -708

   /* update trade with the new status */
   update dbo.trade 
   set trade_status_code = 'DELETE',
       trade_mod_date = @newTradeModDate,
       trade_mod_init = @modifierInit,
       trans_id = @newTransId
   where trade_num = @tradeNum and
         trans_id = @transId
   if (@@rowcount != 1)
      return -709

   select @orderTypeCode = order_type_code 
   from dbo.trade_order 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   if (@@rowCount != 1)
      return -715

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
         is not done, there is not easy and fast method of finding all deleted fills.
      */
      update dbo.trade_item_fill 
      set fill_status = 'D', 
          trans_id = @newTransId
      where trade_num = @tradeNum and 
            order_num = @orderNum

      delete from dbo.trade_item_fill 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      if (@@rowcount != @rowCount)
         return -716
   end

   if (@orderTypeCode = 'FUTURE') 
   begin
      select @temp = trade_num 
      from dbo.trade_item_fut 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      select @rowCount = @@rowcount
      if (@rowCount = 0)
         return -717

      delete from dbo.trade_item_fut 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      if (@@rowcount != @rowCount)
         return -718
   end
   else if (@orderTypeCode = 'EXCHGOPT') 
   begin
      select @temp = trade_num 
      from dbo.trade_item_exch_opt 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      select @rowCount = @@rowcount
      if (@rowCount = 0)
         return -719

      delete from dbo.trade_item_exch_opt 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      if (@@rowcount != @rowCount)
         return -720
   end
   else if (@orderTypeCode = 'PHYSICAL') 
   begin
      select @temp = trade_num 
      from dbo.trade_item_wet_phy 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      select @rowCount = @@rowcount
      if (@rowCount = 0)
         return -726

      delete from dbo.trade_item_wet_phy 
      where trade_num = @tradeNum and 
            order_num = @orderNum
      if (@@rowcount != @rowCount)
         return -727
   end
   select @temp = trade_num 
   from dbo.trade_item 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   select @rowCount = @@rowcount
   if (@rowCount = 0)
      return -721

   delete from dbo.trade_item 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   if (@@rowcount != @rowCount)
      return -722

   delete from dbo.trade_order_on_exch 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   if (@@rowcount != 1)
   return -734

   delete from dbo.trade_order 
   where trade_num = @tradeNum and 
         order_num = @orderNum
   if (@@rowcount != 1)
      return -723
   return @tradeNum
GO
GRANT EXECUTE ON  [dbo].[inhouse_delete_trade] TO [next_usr]
GO
